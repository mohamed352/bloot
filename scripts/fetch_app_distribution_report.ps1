# Fetches all releases, feedback, testers, and groups from Firebase App Distribution
# and regenerates app_distribution_report.html with fresh data.
#
# Usage: powershell -ExecutionPolicy Bypass -File scripts\fetch_app_distribution_report.ps1

$ErrorActionPreference = "Stop"

$ProjectId = "bloot-89b2b"
$ProjectNumber = "738592764893"
$AppId = "1:738592764893:android:e9cf7172926e3a227efc34"
$BaseApi = "https://firebaseappdistribution.googleapis.com/v1"
$OutputFile = Join-Path $PSScriptRoot "..\app_distribution_report.html"

Write-Host "Fetching access token..." -ForegroundColor Cyan
$token = gcloud auth print-access-token 2>$null
if (-not $token) {
    Write-Error "Failed to get gcloud access token. Run 'gcloud auth login' first."
    exit 1
}

$headers = @{
    Authorization = "Bearer $token"
    "x-goog-user-project" = $ProjectId
}

function Invoke-ApiGet($endpoint) {
    $url = "$BaseApi$endpoint"
    try {
        $resp = Invoke-WebRequest -Uri $url -Headers $headers -Method Get -UseBasicParsing
        return $resp.Content | ConvertFrom-Json
    } catch {
        $status = $_.Exception.Response.StatusCode
        $reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        $body = $reader.ReadToEnd()
        Write-Warning "API call failed: $status - $body"
        return $null
    }
}

# --- Fetch releases ---
Write-Host "Fetching releases..." -ForegroundColor Cyan
$releasesData = Invoke-ApiGet("/projects/$ProjectNumber/apps/$AppId/releases?pageSize=100")
$releases = $releasesData.releases
if (-not $releases) {
    Write-Warning "No releases found or API error."
    $releases = @()
}
Write-Host "Found $($releases.Count) releases" -ForegroundColor Green

# --- Fetch feedback for each release ---
$allFeedback = @()
foreach ($rel in $releases) {
    $relName = $rel.name  # e.g. projects/.../apps/.../releases/xxx
    Write-Host "  Fetching feedback for release $($rel.displayVersion)..." -ForegroundColor Gray
    $fbData = Invoke-ApiGet("/$relName/feedbackReports?pageSize=100")
    if ($fbData -and $fbData.feedbackReports) {
        foreach ($fb in $fbData.feedbackReports) {
            $fb | Add-Member -NotePropertyName releaseName -NotePropertyValue $rel.name
            $fb | Add-Member -NotePropertyName releaseVersion -NotePropertyValue $rel.displayVersion
            $fb | Add-Member -NotePropertyName releaseBuild -NotePropertyValue $rel.buildVersion
            $allFeedback += $fb
        }
    }
}
Write-Host "Total feedback reports: $($allFeedback.Count)" -ForegroundColor Green

# --- Fetch testers ---
Write-Host "Fetching testers..." -ForegroundColor Cyan
$testersData = Invoke-ApiGet("/projects/$ProjectNumber/testers?pageSize=100")
$testers = $testersData.testers
if (-not $testers) { $testers = @() }
Write-Host "Found $($testers.Count) testers" -ForegroundColor Green

# --- Fetch groups ---
Write-Host "Fetching groups..." -ForegroundColor Cyan
$groupsData = Invoke-ApiGet("/projects/$ProjectNumber/groups?pageSize=100")
$groups = $groupsData.groups
if (-not $groups) { $groups = @() }
Write-Host "Found $($groups.Count) groups" -ForegroundColor Green

# --- Build HTML ---
Write-Host "Generating HTML report..." -ForegroundColor Cyan

$now = (Get-Date).ToString("MMMM d, yyyy")

# Stats
$totalFeedback = $allFeedback.Count
$totalTesters = $testers.Count
$totalGroups = $groups.Count

# Build releases HTML
$releasesHtml = ""
foreach ($rel in $releases) {
    $ver = $rel.displayVersion
    $build = $rel.buildVersion
    $relId = $rel.name -replace ".*/"
    $date = ""
    if ($rel.createTime) {
        try { $date = ([DateTimeOffset]$rel.createTime).LocalDateTime.ToString("MMMM d, yyyy 'at' h:mm tt UTC+3") } catch { $date = $rel.createTime }
    }
    $invited = "-"
    $accepted = "-"
    $downloaded = "-"
    $fbCount = ($allFeedback | Where-Object { $_.releaseName -eq $rel.name }).Count

    $consoleUrl = if ($rel.firebaseConsoleUri) { $rel.firebaseConsoleUri } else { "https://console.firebase.google.com/project/$ProjectId/appdistribution/app/android:com.bloot.app/releases/$relId" }
    $testerUrl = if ($rel.testingUri) { $rel.testingUri } else { "https://appdistribution.firebase.google.com/testerapps/$AppId/releases/$relId" }

    $expiry = ""
    if ($rel.expireTime) {
        try { $expiry = ([DateTimeOffset]$rel.expireTime).LocalDateTime.ToString("MMM d, yyyy") } catch { $expiry = $rel.expireTime }
    }

    # Feedback items
    $relFeedback = $allFeedback | Where-Object { $_.releaseName -eq $rel.name }
    $fbHtml = ""
    if ($relFeedback.Count -eq 0) {
        $fbHtml = '<div class="feedback-item no-feedback">No feedback reports for this release</div>'
    } else {
        foreach ($fb in $relFeedback) {
            # tester field is a resource name: projects/{projectNumber}/testers/{email}
            $testerEmail = ""
            $testerName = "Unknown"
            if ($fb.tester) {
                $parts = $fb.tester -split "/"
                $testerEmail = $parts[-1] -replace "%40", "@"
                $testerName = ($testerEmail -split "@")[0]
            }
            $initial = if ($testerName -and $testerName.Length -gt 0) { $testerName.Substring(0,1).ToUpper() } else { "?" }
            $fbDate = ""
            if ($fb.createTime) {
                try { $fbDate = ([DateTimeOffset]$fb.createTime).UtcDateTime.ToString("MMM d, h:mm tt UTC") } catch { $fbDate = $fb.createTime }
            }
            $fbText = $fb.text -replace '"', '&quot;' -replace '<', '&lt;' -replace '>', '&gt;'
            $screenshotHtml = ""
            if ($fb.screenshotUri) {
                $screenshotHtml = "<a class=`"feedback-screenshot`" href=`"$($fb.screenshotUri)`" target=`"_blank`">📸 Screenshot</a>"
            }
            $fbHtml += "<div class=`"feedback-item`"><div class=`"feedback-header`"><div class=`"feedback-tester`"><div class=`"avatar`">$initial</div><div><div class=`"name`">$testerName</div><div class=`"email`">$testerEmail</div></div></div><div class=`"feedback-time`">$fbDate</div></div><div class=`"feedback-text`">`"$fbText`"</div>$screenshotHtml</div>`n"
        }
    }

    $releasesHtml += @"
<div class="release-card"><div class="release-header"><div class="release-info"><div class="release-version-box"><div class="ver">$ver</div><div class="build">Build $build</div></div><div class="release-meta"><div class="title">Release</div><div class="date">$date</div></div></div><div class="release-stats"><div class="release-stat"><div class="num">$invited</div><div class="lbl">Invited</div></div><div class="release-stat"><div class="num">$accepted</div><div class="lbl">Accepted</div></div><div class="release-stat"><div class="num">$downloaded</div><div class="lbl">Downloaded</div></div><div class="release-stat"><div class="num" style="color:var(--warning)">$fbCount</div><div class="lbl">Feedback</div></div></div></div><div class="release-body"><div class="release-links"><a class="release-link console" href="$consoleUrl" target="_blank">🔗 Console</a><a class="release-link testing" href="$testerUrl" target="_blank">🧪 Tester</a></div><div class="expiry">⏳ Expires: $expiry</div><div class="feedback-list">
$fbHtml</div></div></div>
"@
}

# Build testers HTML
$testersHtml = ""
foreach ($t in $testers) {
    $name = $t.name -replace ".*/" -replace "%40", "@"
    $email = $name
    $displayName = ($name -split "@")[0]
    $initial = if ($displayName) { $displayName.Substring(0,1).ToUpper() } else { "?" }
    $testersHtml += "<div class=`"tester-card`"><div class=`"tester-avatar`">$initial</div><div class=`"tester-info`"><div class=`"name`">$displayName</div><div class=`"email`">$email</div><div class=`"meta`"><span class=`"tester-tag`">Tester</span></div></div></div>`n"
}

# Build groups HTML
$groupsHtml = ""
foreach ($g in $groups) {
    $gname = $g.name -replace ".*/"
    $gcount = if ($g.testerCount) { $g.testerCount } else { 0 }
    if (-not $gname) { $gname = "Unknown" }
    $groupsHtml += "<div class=`"group-card`"><div class=`"name`">🏷️ $gname</div><div class=`"group-stats`"><div class=`"group-stat`"><div class=`"num`">$gcount</div><div class=`"lbl`">Testers</div></div></div></div>`n"
}

# Build AI summary
$aiItems = ""
foreach ($fb in $allFeedback) {
    $text = $fb.text -replace '"', '&quot;' -replace '<', '&lt;' -replace '>', '&gt;'
    $build = $fb.releaseBuild
    $aiItems += "<li>💬 <strong>Feedback (Build $build):</strong> `"$text`"</li>`n"
}

$html = @"
<!DOCTYPE html>
<html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Bloot - Firebase App Distribution Report</title>
<style>
:root{--bg:#0f0f23;--surface:#1a1a3e;--surface2:#222250;--accent:#ff6b35;--accent2:#f7931e;--primary:#4f46e5;--primary-light:#818cf8;--success:#10b981;--warning:#f59e0b;--danger:#ef4444;--text:#e2e8f0;--text-dim:#94a3b8;--border:rgba(255,255,255,0.08);--radius:16px}
*{margin:0;padding:0;box-sizing:border-box}body{font-family:'Segoe UI',system-ui,sans-serif;background:var(--bg);color:var(--text);line-height:1.6}
.header{background:linear-gradient(135deg,#1a1a3e,#2d1b69,#1a1a3e);border-bottom:1px solid var(--border);padding:28px 0;position:sticky;top:0;z-index:100;backdrop-filter:blur(12px)}
.header-content{max-width:1200px;margin:0 auto;padding:0 24px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:16px}
.logo-area{display:flex;align-items:center;gap:14px}
.logo-icon{width:48px;height:48px;background:linear-gradient(135deg,var(--accent),var(--accent2));border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:24px;font-weight:800;color:#fff;box-shadow:0 4px 20px rgba(255,107,53,0.3)}
.header h1{font-size:22px;font-weight:700}.header h1 span{color:var(--text-dim);font-weight:400;font-size:14px;display:block}
.header-badges{display:flex;gap:10px;flex-wrap:wrap}
.badge{padding:6px 14px;border-radius:20px;font-size:12px;font-weight:600;display:flex;align-items:center;gap:6px}
.badge-p{background:rgba(79,70,229,0.15);color:var(--primary-light);border:1px solid rgba(79,70,229,0.3)}
.badge-b{background:rgba(255,107,53,0.15);color:var(--accent);border:1px solid rgba(255,107,53,0.3)}
.badge-a{background:rgba(16,185,129,0.15);color:var(--success);border:1px solid rgba(16,185,129,0.3)}
.container{max-width:1200px;margin:0 auto;padding:32px 24px}
.stats-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:20px;margin-bottom:36px}
.stat-card{background:var(--surface);border:1px solid var(--border);border-radius:var(--radius);padding:24px;position:relative;overflow:hidden;transition:transform .2s,box-shadow .2s}
.stat-card:hover{transform:translateY(-2px);box-shadow:0 8px 30px rgba(0,0,0,0.3)}
.stat-card::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;border-radius:var(--radius) var(--radius) 0 0}
.stat-card.r1::before{background:linear-gradient(90deg,var(--primary),var(--primary-light))}
.stat-card.r2::before{background:linear-gradient(90deg,var(--success),#34d399)}
.stat-card.r3::before{background:linear-gradient(90deg,var(--warning),#fbbf24)}
.stat-card.r4::before{background:linear-gradient(90deg,var(--accent),var(--accent2))}
.stat-icon{font-size:28px;margin-bottom:12px}.stat-value{font-size:36px;font-weight:800;line-height:1}
.stat-label{color:var(--text-dim);font-size:13px;margin-top:6px;text-transform:uppercase;letter-spacing:.5px}
.section{margin-bottom:40px}.section-title{font-size:20px;font-weight:700;margin-bottom:20px;display:flex;align-items:center;gap:10px}
.section-title .dot{width:8px;height:8px;border-radius:50%}
.dot.r1{background:var(--primary)}.dot.r2{background:var(--success)}.dot.r3{background:var(--warning)}.dot.r4{background:var(--accent)}
.release-card{background:var(--surface);border:1px solid var(--border);border-radius:var(--radius);margin-bottom:20px;overflow:hidden;transition:box-shadow .2s}
.release-card:hover{box-shadow:0 8px 30px rgba(0,0,0,0.2)}
.release-header{padding:20px 24px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;border-bottom:1px solid var(--border)}
.release-info{display:flex;align-items:center;gap:16px}
.release-version-box{background:linear-gradient(135deg,var(--primary),var(--primary-light));border-radius:12px;padding:10px 16px;text-align:center;min-width:80px}
.release-version-box .ver{font-size:18px;font-weight:800}.release-version-box .build{font-size:11px;opacity:.8}
.release-meta .title{font-size:16px;font-weight:600}.release-meta .date{font-size:13px;color:var(--text-dim)}
.release-stats{display:flex;gap:16px}.release-stat{text-align:center}.release-stat .num{font-size:20px;font-weight:700}.release-stat .lbl{font-size:11px;color:var(--text-dim);text-transform:uppercase}
.release-body{padding:20px 24px}.release-links{display:flex;gap:12px;flex-wrap:wrap;margin-bottom:16px}
.release-link{padding:8px 16px;border-radius:8px;font-size:13px;font-weight:600;text-decoration:none;display:inline-flex;align-items:center;gap:6px;transition:opacity .2s}.release-link:hover{opacity:.85}
.release-link.console{background:rgba(79,70,229,0.15);color:var(--primary-light);border:1px solid rgba(79,70,229,0.3)}
.release-link.testing{background:rgba(16,185,129,0.15);color:var(--success);border:1px solid rgba(16,185,129,0.3)}
.release-link.download{background:rgba(255,107,53,0.15);color:var(--accent);border:1px solid rgba(255,107,53,0.3)}
.expiry{font-size:12px;color:var(--text-dim);display:flex;align-items:center;gap:6px}
.feedback-list{display:flex;flex-direction:column;gap:12px;margin-top:16px}
.feedback-item{background:var(--surface2);border:1px solid var(--border);border-left:3px solid var(--warning);border-radius:10px;padding:16px 20px}
.feedback-item.no-feedback{border-left-color:var(--text-dim);text-align:center;color:var(--text-dim);font-style:italic;padding:20px}
.feedback-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:8px;flex-wrap:wrap;gap:8px}
.feedback-tester{display:flex;align-items:center;gap:8px;font-size:13px}
.feedback-tester .avatar{width:28px;height:28px;border-radius:50%;background:linear-gradient(135deg,var(--accent),var(--accent2));display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:700;color:#fff}
.feedback-tester .name{font-weight:600}.feedback-tester .email{color:var(--text-dim)}.feedback-time{font-size:12px;color:var(--text-dim)}
.feedback-text{font-size:14px;color:var(--text)}
.feedback-screenshot{margin-top:10px;display:inline-block;padding:6px 14px;border-radius:8px;background:rgba(245,158,11,0.1);color:var(--warning);font-size:12px;font-weight:600;text-decoration:none;border:1px solid rgba(245,158,11,0.2)}.feedback-screenshot:hover{background:rgba(245,158,11,0.2)}
.testers-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:16px}
.tester-card{background:var(--surface);border:1px solid var(--border);border-radius:var(--radius);padding:20px;display:flex;align-items:flex-start;gap:16px}
.tester-avatar{width:48px;height:48px;border-radius:50%;background:linear-gradient(135deg,var(--success),#34d399);display:flex;align-items:center;justify-content:center;font-size:20px;font-weight:700;color:#fff;flex-shrink:0}
.tester-info .name{font-size:16px;font-weight:600}.tester-info .email{font-size:13px;color:var(--text-dim);margin-bottom:8px}
.tester-info .meta{display:flex;gap:12px;flex-wrap:wrap}.tester-tag{padding:4px 10px;border-radius:6px;font-size:11px;font-weight:600;background:var(--surface2);color:var(--text-dim)}.tester-tag.active{background:rgba(16,185,129,0.15);color:var(--success)}
.groups-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:16px}
.group-card{background:var(--surface);border:1px solid var(--border);border-radius:var(--radius);padding:20px}
.group-card .name{font-size:18px;font-weight:700;margin-bottom:12px}.group-stats{display:flex;gap:20px}.group-stat .num{font-size:24px;font-weight:800}.group-stat .lbl{font-size:11px;color:var(--text-dim);text-transform:uppercase}
.ai-summary{background:linear-gradient(135deg,var(--surface),var(--surface2));border:1px solid var(--border);border-radius:var(--radius);padding:28px;margin-bottom:40px;position:relative;overflow:hidden}
.ai-summary h2{font-size:20px;font-weight:700;margin-bottom:16px;display:flex;align-items:center;gap:10px}
.ai-badge{padding:4px 12px;border-radius:6px;font-size:11px;font-weight:700;background:linear-gradient(135deg,var(--primary),var(--primary-light));color:#fff}
.ai-summary p{font-size:14px;color:var(--text-dim);margin-bottom:12px}.ai-summary ul{list-style:none;padding:0}
.ai-summary li{padding:10px 0;border-bottom:1px solid var(--border);font-size:14px;display:flex;align-items:flex-start;gap:10px}.ai-summary li:last-child{border-bottom:none}
.footer{text-align:center;padding:24px;color:var(--text-dim);font-size:12px;border-top:1px solid var(--border);margin-top:40px}
@media(max-width:640px){.header-content{flex-direction:column;align-items:flex-start}.release-header{flex-direction:column;align-items:flex-start}.release-stats{width:100%;justify-content:space-around}}
</style></head><body>
<div class="header"><div class="header-content"><div class="logo-area"><div class="logo-icon">B</div><h1>Bloot <span>Firebase App Distribution Report</span></h1></div>
<div class="header-badges"><span class="badge badge-p">bloot-89b2b</span><span class="badge badge-b">Blaze Plan</span><span class="badge badge-a">Android</span></div></div></div>
<div class="container">
<div class="stats-grid">
<div class="stat-card r1"><div class="stat-icon">📦</div><div class="stat-value">$($releases.Count)</div><div class="stat-label">Total Releases</div></div>
<div class="stat-card r2"><div class="stat-icon">👥</div><div class="stat-value">$totalTesters</div><div class="stat-label">Testers</div></div>
<div class="stat-card r3"><div class="stat-icon">💬</div><div class="stat-value">$totalFeedback</div><div class="stat-label">Feedback Reports</div></div>
<div class="stat-card r4"><div class="stat-icon">🏷️</div><div class="stat-value">$totalGroups</div><div class="stat-label">Tester Groups</div></div>
</div>
<div class="ai-summary"><h2>Feedback Summary <span class="ai-badge">LIVE DATA</span></h2>
<p>Report for <strong>Bloot</strong> Android app (<code>com.bloot.app</code>), project <code>bloot-89b2b</code>. Contact: mohamedmostafa5830@gmail.com</p>
<ul>
$aiItems</ul></div>
<div class="section"><div class="section-title"><span class="dot r1"></span> Releases ($($releases.Count))</div>
$releasesHtml</div>
<div class="section"><div class="section-title"><span class="dot r2"></span> Testers ($totalTesters)</div>
<div class="testers-grid">
$testersHtml</div></div>
<div class="section"><div class="section-title"><span class="dot r4"></span> Groups ($totalGroups)</div>
<div class="groups-grid">
$groupsHtml</div></div>
</div>
<div class="footer">Generated on $now — Firebase App Distribution Report for Bloot (bloot-89b2b)</div>
</body></html>
"@

$html | Out-File -FilePath $OutputFile -Encoding utf8 -NoNewline
Write-Host "Report saved to $OutputFile" -ForegroundColor Green
Write-Host "Done! Releases: $($releases.Count), Feedback: $totalFeedback, Testers: $totalTesters, Groups: $totalGroups" -ForegroundColor Cyan
