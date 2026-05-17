// Bloot Admin — Shared Utilities
// Adapted from DoorCut admin with dark theme support

// --- Toast Notifications ---
function showToast(message, type = 'info') {
    const colors = {
        success: 'bg-green-600 border-green-500',
        error: 'bg-red-600 border-red-500',
        warning: 'bg-yellow-600 border-yellow-500',
        info: 'bg-purple-600 border-purple-500'
    };
    const icons = {
        success: 'check_circle',
        error: 'error',
        warning: 'warning',
        info: 'info'
    };
    const toast = document.createElement('div');
    toast.className = `fixed top-4 right-4 z-50 flex items-center gap-3 px-5 py-3 rounded-lg border shadow-2xl text-white ${colors[type] || colors.info} transition-all duration-300 translate-x-full`;
    toast.innerHTML = `
        <span class="material-symbols-outlined text-xl">${icons[type] || icons.info}</span>
        <span class="text-sm font-medium">${message}</span>
    `;
    document.body.appendChild(toast);
    requestAnimationFrame(() => {
        toast.classList.remove('translate-x-full');
    });
    setTimeout(() => {
        toast.classList.add('translate-x-full');
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// --- Modal ---
function createModal(title, contentHtml, actionsHtml = '') {
    const overlay = document.createElement('div');
    overlay.className = 'fixed inset-0 z-40 bg-black/60 flex items-center justify-center p-4';
    overlay.innerHTML = `
        <div class="bg-b-surface-elevated rounded-2xl border border-b-border max-w-lg w-full max-h-[80vh] overflow-hidden shadow-2xl">
            <div class="flex items-center justify-between p-6 border-b border-b-border">
                <h3 class="text-lg font-semibold text-b-on-surface">${title}</h3>
                <button onclick="this.closest('.fixed').remove()" class="text-b-on-surface-muted hover:text-b-on-surface transition-colors">
                    <span class="material-symbols-outlined">close</span>
                </button>
            </div>
            <div class="p-6 overflow-y-auto max-h-[60vh] text-b-on-surface-muted">${contentHtml}</div>
            ${actionsHtml ? `<div class="flex items-center justify-end gap-3 p-6 border-t border-b-border">${actionsHtml}</div>` : ''}
        </div>
    `;
    overlay.addEventListener('click', (e) => {
        if (e.target === overlay) overlay.remove();
    });
    document.body.appendChild(overlay);
    return overlay;
}

// --- Confirm Dialog ---
function confirmDialog(message, onConfirm, onCancel) {
    const overlay = createModal(
        'Confirm Action',
        `<p class="text-b-on-surface-muted">${message}</p>`,
        `
            <button onclick="this.closest('.fixed').remove()" class="px-5 py-2.5 rounded-full border border-b-border text-b-on-surface-muted hover:bg-b-surface-muted transition-colors text-sm font-medium">Cancel</button>
            <button id="bl-confirm-btn" class="px-5 py-2.5 rounded-full bg-b-purple text-white font-medium text-sm hover:bg-b-purple-dark transition-colors">Confirm</button>
        `
    );
    overlay.querySelector('#bl-confirm-btn').addEventListener('click', () => {
        overlay.remove();
        if (onConfirm) onConfirm();
    });
}

// --- Table CSV Export ---
function exportTableToCSV(tableSelector, filename = 'export.csv') {
    const table = document.querySelector(tableSelector);
    if (!table) return;
    const rows = table.querySelectorAll('tr');
    let csv = [];
    rows.forEach(row => {
        const cols = row.querySelectorAll('td, th');
        const rowData = Array.from(cols).map(col => `"${col.textContent.replace(/"/g, '""').trim()}"`);
        csv.push(rowData.join(','));
    });
    const blob = new Blob([csv.join('\n')], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = filename;
    link.click();
}

// --- Live Table Filter ---
function filterTable(input, tableSelector, columnIndices = null) {
    const filter = input.value.toLowerCase();
    const table = document.querySelector(tableSelector);
    if (!table) return;
    const rows = table.querySelectorAll('tbody tr');
    rows.forEach(row => {
        const cells = row.querySelectorAll('td');
        let match = false;
        if (columnIndices) {
            columnIndices.forEach(i => {
                if (cells[i] && cells[i].textContent.toLowerCase().includes(filter)) match = true;
            });
        } else {
            cells.forEach(cell => {
                if (cell.textContent.toLowerCase().includes(filter)) match = true;
            });
        }
        row.style.display = match || filter === '' ? '' : 'none';
    });
}

// --- Tab Switching ---
function initTabs(containerSelector, callback) {
    const container = document.querySelector(containerSelector);
    if (!container) return;
    const tabs = container.querySelectorAll('[data-tab]');
    const contents = container.querySelectorAll('[data-tab-content]');
    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            tabs.forEach(t => t.classList.remove('bg-b-purple', 'text-white'));
            tabs.forEach(t => t.classList.add('text-b-on-surface-muted', 'hover:text-b-on-surface'));
            tab.classList.add('bg-b-purple', 'text-white');
            tab.classList.remove('text-b-on-surface-muted', 'hover:text-b-on-surface');
            const target = tab.getAttribute('data-tab');
            contents.forEach(content => {
                content.style.display = content.getAttribute('data-tab-content') === target ? '' : 'none';
            });
            if (callback) callback(target);
        });
    });
}

// --- Badge Count Updater ---
function updateBadgeCount(selector, count) {
    const el = document.querySelector(selector);
    if (!el) return;
    el.textContent = count;
    el.style.display = count > 0 ? '' : 'none';
}

// --- Sidebar Toggle (for mobile) ---
function toggleSidebar() {
    const sidebar = document.querySelector('#sidebar');
    if (sidebar) {
        sidebar.classList.toggle('-translate-x-full');
        sidebar.classList.toggle('translate-x-0');
    }
}