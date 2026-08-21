$port=8080
$url="http://localhost:$port/"
$scriptDir=$PSScriptRoot
if([string]::IsNullOrEmpty($scriptDir)){$scriptDir=(Get-Location).Path}
$jsonFile=Join-Path $scriptDir "kanban_data.json"

$htmlContent=@'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>PowerShell Kanban</title>
<script src="https://cdn.tailwindcss.com"></script>
<script>tailwind.config={darkMode:'class'}</script>
<style>.kanban-col{min-height:250px}.drag-over{background-color:rgba(0,0,0,0.05);border-radius:0.5rem;}.dark .drag-over{background-color:rgba(255,255,255,0.05);}</style>
</head>
<body class="bg-slate-100 dark:bg-slate-900 text-slate-800 dark:text-slate-200 font-sans p-4 md:p-8 transition-colors duration-200">
<div class="max-w-7xl mx-auto">

<div class="flex justify-between items-center mb-8">
<div class="w-20"></div>
<h1 class="text-3xl font-extrabold text-slate-700 dark:text-slate-200">&#128204; PowerShell Kanban</h1>
<div class="flex space-x-2">
<button onclick="toggleLang()" id="langBtn" class="w-10 h-10 bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg shadow-sm hover:bg-slate-50 dark:hover:bg-slate-700 transition-colors font-bold text-sm text-slate-600 dark:text-slate-300" title="Mudar Idioma">EN</button>
<button onclick="toggleTheme()" class="w-10 h-10 bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg shadow-sm hover:bg-slate-50 dark:hover:bg-slate-700 transition-colors" title="Alternar Tema">&#127762;</button>
</div>
</div>

<!-- Filtros -->
<div class="bg-white dark:bg-slate-800 p-4 rounded-xl shadow-sm border border-slate-200 dark:border-slate-700 mb-6 flex flex-col md:flex-row gap-4">
<div class="flex-1"><label class="block text-sm font-semibold mb-1 text-slate-600 dark:text-slate-400" data-i18n="searchLabel">&#128269; Buscar por T&iacute;tulo ou Projeto</label><input type="text" id="filterText" oninput="render()" class="w-full border dark:border-slate-600 rounded p-2 outline-none focus:ring-2 focus:ring-blue-500 dark:bg-slate-700 dark:text-white" data-i18n-placeholder="searchPlaceholder" placeholder="Digite para buscar..."></div>
<div><label class="block text-sm font-semibold mb-1 text-slate-600 dark:text-slate-400" data-i18n="dateFilterLabel">&#128197; Filtrar por Data</label><input type="date" id="filterDate" onchange="render()" class="w-full border dark:border-slate-600 rounded p-2 outline-none focus:ring-2 focus:ring-blue-500 dark:bg-slate-700 dark:text-white"></div>
<div class="flex items-end"><button onclick="limparFiltros()" data-i18n="clearBtn" class="bg-slate-200 dark:bg-slate-700 hover:bg-slate-300 dark:hover:bg-slate-600 text-slate-700 dark:text-white font-bold py-2 px-4 rounded w-full md:w-auto">Limpar</button></div>
</div>

<!-- Formulario -->
<div class="bg-white dark:bg-slate-800 p-6 rounded-xl shadow-sm border border-slate-200 dark:border-slate-700 mb-8">
<form id="cardForm" class="grid grid-cols-1 md:grid-cols-4 gap-4">
<input type="hidden" id="cardId">
<div class="md:col-span-2"><label class="block text-sm font-semibold mb-1 text-slate-600 dark:text-slate-400" data-i18n="titleLabel">T&iacute;tulo</label><input type="text" id="title" required class="w-full border dark:border-slate-600 rounded p-2 outline-none focus:ring-2 focus:ring-blue-500 dark:bg-slate-700 dark:text-white"></div>
<div class="md:col-span-2"><label class="block text-sm font-semibold mb-1 text-slate-600 dark:text-slate-400" data-i18n="projectLabel">Projeto</label><input type="text" id="project" required class="w-full border dark:border-slate-600 rounded p-2 outline-none focus:ring-2 focus:ring-blue-500 dark:bg-slate-700 dark:text-white"></div>

<div class="md:col-span-2"><label class="block text-sm font-semibold mb-1 text-blue-600 dark:text-blue-400" data-i18n="mainDateLabel">Data Principal (Ordena&ccedil;&atilde;o)</label><input type="date" id="date" required class="w-full border dark:border-slate-600 rounded p-2 outline-none focus:ring-2 focus:ring-blue-500 dark:bg-slate-700 dark:text-white"></div>
<div class="md:col-span-2"><label class="block text-sm font-semibold mb-1 text-slate-600 dark:text-slate-400" data-i18n="colLabel">Coluna</label>
<select id="column" class="w-full border dark:border-slate-600 rounded p-2 outline-none focus:ring-2 focus:ring-blue-500 dark:bg-slate-700 dark:text-white">
<option value="backlog" data-i18n="optBacklog">Backlog</option><option value="desenvolvendo" data-i18n="optDev">Desenvolvendo</option><option value="concluido" data-i18n="optDone">Conclu&iacute;do</option>
</select></div>

<div class="md:col-span-4"><label class="block text-sm font-semibold mb-1 text-slate-600 dark:text-slate-400" data-i18n="descLabel">Descri&ccedil;&atilde;o</label><textarea id="description" rows="2" class="w-full border dark:border-slate-600 rounded p-2 outline-none focus:ring-2 focus:ring-blue-500 dark:bg-slate-700 dark:text-white"></textarea></div>

<!-- SECAO DE APONTAMENTO DE HORAS -->
<div class="md:col-span-4 border-t dark:border-slate-700 pt-4 mt-2">
<label class="block text-sm font-semibold mb-2 text-slate-600 dark:text-slate-400" data-i18n="timeLogsLabel">Registros de Horas</label>
<div class="flex flex-wrap gap-2 mb-2 items-end bg-slate-50 dark:bg-slate-800/50 p-3 rounded border dark:border-slate-700">
<div><label class="text-xs text-slate-500" data-i18n="dateLabel">Data</label><input type="date" id="logDate" class="w-full border dark:border-slate-600 rounded p-1.5 outline-none text-sm dark:bg-slate-700 dark:text-white"></div>
<div><label class="text-xs text-slate-500" data-i18n="startLabel">In&iacute;cio</label><input type="time" id="logStart" class="w-full border dark:border-slate-600 rounded p-1.5 outline-none text-sm dark:bg-slate-700 dark:text-white" onchange="calcLog()"></div>
<div><label class="text-xs text-slate-500" data-i18n="endLabel">T&eacute;rmino</label><input type="time" id="logEnd" class="w-full border dark:border-slate-600 rounded p-1.5 outline-none text-sm dark:bg-slate-700 dark:text-white" onchange="calcLog()"></div>
<div><label class="text-xs text-slate-500" data-i18n="hoursLabel">Horas</label><input type="text" id="logHours" readonly class="w-24 border dark:border-slate-600 rounded p-1.5 outline-none text-sm bg-slate-100 dark:bg-slate-600 dark:text-slate-300 cursor-not-allowed"></div>
<button type="button" onclick="addLog()" class="bg-slate-300 hover:bg-slate-400 dark:bg-slate-600 dark:hover:bg-slate-500 text-slate-800 dark:text-white font-bold py-1.5 px-4 rounded text-sm transition-colors" data-i18n="addBtn">Adicionar</button>
</div>
<div id="logsContainer" class="space-y-2 max-h-32 overflow-y-auto mt-2"></div>
</div>

<div class="md:col-span-4 mt-2"><button type="submit" data-i18n="saveBtn" class="w-full bg-blue-600 text-white font-bold py-3 rounded hover:bg-blue-700 transition-colors">Salvar Card</button></div>
</form>
</div>

<!-- Board -->
<div class="grid grid-cols-1 md:grid-cols-3 gap-6">
<div class="bg-slate-200 dark:bg-slate-800/50 rounded-xl p-4 shadow-inner"><h2 class="text-lg font-bold mb-4 text-slate-700 dark:text-slate-300 uppercase tracking-wide" data-i18n="optBacklog">Backlog</h2><div id="col-backlog" class="kanban-col space-y-4" ondrop="drop(event, 'backlog')" ondragover="allowDrop(event)"></div></div>
<div class="bg-blue-50 dark:bg-blue-900/10 rounded-xl p-4 shadow-inner border border-blue-100 dark:border-blue-900"><h2 class="text-lg font-bold mb-4 text-blue-800 dark:text-blue-400 uppercase tracking-wide" data-i18n="optDev">Desenvolvendo</h2><div id="col-desenvolvendo" class="kanban-col space-y-4" ondrop="drop(event, 'desenvolvendo')" ondragover="allowDrop(event)"></div></div>
<div class="bg-green-50 dark:bg-green-900/10 rounded-xl p-4 shadow-inner border border-green-100 dark:border-green-900"><h2 class="text-lg font-bold mb-4 text-green-800 dark:text-green-400 uppercase tracking-wide" data-i18n="optDone">Conclu&iacute;do</h2><div id="col-concluido" class="kanban-col space-y-4" ondrop="drop(event, 'concluido')" ondragover="allowDrop(event)"></div></div>
</div>
</div>

<!-- Toast Container -->
<div id="toastContainer" class="fixed bottom-4 right-4 z-50 flex flex-col gap-2 pointer-events-none"></div>

<script>
// --- DICIONARIO DE IDIOMAS ---
const i18n = {
  pt: {
    searchLabel: "&#128269; Buscar por T&iacute;tulo ou Projeto", searchPlaceholder: "Digite para buscar...",
    dateFilterLabel: "&#128197; Filtrar por Data", clearBtn: "Limpar",
    titleLabel: "T&iacute;tulo", projectLabel: "Projeto", dateLabel: "Data", mainDateLabel: "Data Principal (Ordena&ccedil;&atilde;o)",
    startLabel: "In&iacute;cio", endLabel: "T&eacute;rmino", hoursLabel: "Gasto", timeLogsLabel: "Registros de Horas", addBtn: "Adicionar",
    colLabel: "Coluna", optBacklog: "Backlog", optDev: "Desenvolvendo", optDone: "Conclu&iacute;do",
    descLabel: "Descri&ccedil;&atilde;o", saveBtn: "Salvar Card",
    noDate: "Sem data", noLogs: "Sem registros", total: "Total Consolidado:",
    msgMove: "Movido para", msgUpd: "Card atualizado com sucesso!", msgNew: "Novo card criado!",
    msgDelConfirm: "Tem certeza que deseja excluir?", msgDel: "Card exclu&iacute;do!", msgFillLog: "Preencha data e hor&aacute;rios do registro!"
  },
  en: {
    searchLabel: "&#128269; Search by Title or Project", searchPlaceholder: "Type to search...",
    dateFilterLabel: "&#128197; Filter by Date", clearBtn: "Clear",
    titleLabel: "Title", projectLabel: "Project", dateLabel: "Date", mainDateLabel: "Main Date (Sorting)",
    startLabel: "Start", endLabel: "End", hoursLabel: "Spent", timeLogsLabel: "Time Logs", addBtn: "Add",
    colLabel: "Column", optBacklog: "Backlog", optDev: "In Progress", optDone: "Done",
    descLabel: "Description", saveBtn: "Save Card",
    noDate: "No date", noLogs: "No records", total: "Consolidated Total:",
    msgMove: "Moved to", msgUpd: "Card successfully updated!", msgNew: "New card created!",
    msgDelConfirm: "Are you sure you want to delete?", msgDel: "Card deleted!", msgFillLog: "Fill in date and times for the log!"
  }
};

let currentLang = localStorage.lang || 'pt';
function applyLang() {
  document.getElementById('langBtn').innerText = currentLang === 'pt' ? 'EN' : 'PT';
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    if(i18n[currentLang][key]) el.innerHTML = i18n[currentLang][key];
  });
  document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
    const key = el.getAttribute('data-i18n-placeholder');
    if(i18n[currentLang][key]) el.placeholder = i18n[currentLang][key];
  });
  render();
}
function toggleLang() { currentLang = currentLang === 'pt' ? 'en' : 'pt'; localStorage.lang = currentLang; applyLang(); }

// --- TEMA ESCURO ---
if(localStorage.theme==='dark' || (!('theme' in localStorage)&&window.matchMedia('(prefers-color-scheme: dark)').matches)){document.documentElement.classList.add('dark');}
function toggleTheme(){
document.documentElement.classList.toggle('dark');
localStorage.theme = document.documentElement.classList.contains('dark') ? 'dark' : 'light';
}

function showToast(msg, type='success'){
const t=document.createElement('div');
t.className=`px-4 py-3 rounded shadow-lg text-white text-sm font-medium transition-all duration-500 transform translate-y-0 opacity-100 ${type==='success'?'bg-green-600':'bg-red-600'}`;
t.innerHTML = (type==='success'?'&#10004;&#65039; ':'&#9888;&#65039; ') + msg;
document.getElementById('toastContainer').appendChild(t);
setTimeout(()=>{t.classList.add('opacity-0','translate-y-2');setTimeout(()=>t.remove(),500)}, 3000);
}

// --- DADOS E MULTIPLOS REGISTROS ---
let cards=[];
let tempLogs=[];

async function loadData(){
try{
const r=await fetch('/api/data');cards=await r.json();
if(!Array.isArray(cards))cards=[];
// Migracao para estrutura de Multiplos Logs
cards.forEach(c => {
    if(!c.timeLogs) {
        c.timeLogs = [];
        if(c.startTime && c.endTime) {
            c.timeLogs.push({date: c.date||'', startTime: c.startTime, endTime: c.endTime, hours: c.hours||'0h 0m'});
        }
    }
});
applyLang();
}catch(e){}
}

async function saveData(){
try{await fetch('/api/data',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(cards)});}catch(e){}
}

function calcLog(){
const s=document.getElementById('logStart').value;
const e=document.getElementById('logEnd').value;
if(s && e){
const [h1,m1]=s.split(':').map(Number);
const [h2,m2]=e.split(':').map(Number);
let diff=(h2*60+m2)-(h1*60+m1);
if(diff<0) diff+=24*60;
const hrs=Math.floor(diff/60);
const mins=diff%60;
document.getElementById('logHours').value=`${hrs}h ${mins}m`;
}else{document.getElementById('logHours').value='';}
}

function addLog(){
const d=document.getElementById('logDate').value;
const s=document.getElementById('logStart').value;
const e=document.getElementById('logEnd').value;
const h=document.getElementById('logHours').value;
if(d && s && e){
tempLogs.push({date:d, startTime:s, endTime:e, hours:h});
document.getElementById('logDate').value=''; document.getElementById('logStart').value=''; 
document.getElementById('logEnd').value=''; document.getElementById('logHours').value='';
renderLogs();
}else{ showToast(i18n[currentLang].msgFillLog, 'error'); }
}

function removeLog(idx){ tempLogs.splice(idx,1); renderLogs(); }

function renderLogs(){
const c = document.getElementById('logsContainer'); c.innerHTML='';
tempLogs.forEach((l, idx)=>{
const dFormat = l.date.split('-').reverse().join('/');
const el = document.createElement('div');
el.className='flex justify-between items-center bg-white dark:bg-slate-700 p-2 rounded border dark:border-slate-600 text-sm';
el.innerHTML=`<span>&#128197; ${dFormat} | &#9200; ${l.startTime} - ${l.endTime} (${l.hours})</span>
<button type="button" onclick="removeLog(${idx})" class="text-red-500 hover:text-red-700 font-bold px-2">X</button>`;
c.appendChild(el);
});
}

function limparFiltros(){ document.getElementById('filterText').value=''; document.getElementById('filterDate').value=''; render(); }

function render(){
const ft=document.getElementById('filterText').value.toLowerCase();
const fd=document.getElementById('filterDate').value;
['backlog','desenvolvendo','concluido'].forEach(col=>{document.getElementById('col-'+col).innerHTML='';});

let filtered = cards;
if(ft) filtered = filtered.filter(c=>(c.title||'').toLowerCase().includes(ft) || (c.project||'').toLowerCase().includes(ft));
if(fd) filtered = filtered.filter(c=>c.date === fd);

// ORDENACAO INTELIGENTE (Data desc -> Criação desc)
filtered.sort((a, b) => {
    const dA = a.date || ""; const dB = b.date || "";
    if (dA > dB) return -1;
    if (dA < dB) return 1;
    return b.id.localeCompare(a.id);
});

filtered.forEach(c=>{
const el=document.createElement('div');
el.className='bg-white dark:bg-slate-700 p-4 rounded-lg shadow-sm border-l-4 cursor-grab hover:shadow-md relative group flex flex-col h-full';
el.className+=(c.column==='backlog'?' border-slate-500':c.column==='desenvolvendo'?' border-blue-500':' border-green-500');
el.draggable=true; el.id=c.id;
el.ondragstart=(e)=>{e.dataTransfer.setData("id",c.id);setTimeout(()=>el.classList.add('opacity-50'),0);};
el.ondragend=()=>el.classList.remove('opacity-50');

const dataFormatada=c.date?c.date.split('-').reverse().join('/'):i18n[currentLang].noDate;

// Processar Multiplos Logs
let logsHtml = ''; let totalMins = 0;
if(c.timeLogs && c.timeLogs.length > 0) {
    c.timeLogs.forEach(l => {
        const lDate = l.date ? l.date.split('-').reverse().join('/') : '--/--/----';
        logsHtml += `<div class="text-[12px] text-slate-500 dark:text-slate-400 mt-1">&#128197; ${lDate} | &#9200; ${l.startTime} &agrave;s ${l.endTime} (${l.hours})</div>`;
        if(l.startTime && l.endTime) {
            const [h1, m1] = l.startTime.split(':').map(Number);
            const [h2, m2] = l.endTime.split(':').map(Number);
            let diff = (h2*60 + m2) - (h1*60 + m1);
            if(diff < 0) diff += 24*60;
            totalMins += diff;
        }
    });
}
const th = Math.floor(totalMins / 60); const tm = totalMins % 60;
const totalStr = `${th}h ${tm}m`;

el.innerHTML=`
<div class="flex justify-between items-start mb-2"><h3 class="font-bold text-slate-800 dark:text-slate-100 leading-tight pr-2">${c.title}</h3>
<div class="flex space-x-2 shrink-0"><button onclick="editCard('${c.id}')" class="text-slate-400 hover:text-blue-500 dark:hover:text-blue-400">&#9999;&#65039;</button><button onclick="delCard('${c.id}')" class="text-slate-400 hover:text-red-500 dark:hover:text-red-400">&#128465;&#65039;</button></div></div>
<div class="text-xs font-semibold text-slate-500 dark:text-slate-400 mb-1">&#128193; ${c.project}</div>
<div class="text-xs text-blue-600 dark:text-blue-400 font-bold mb-3">&#128197; ${dataFormatada} <span class="font-normal opacity-75">(${i18n[currentLang].mainDateLabel.split(' ')[0]})</span></div>
${c.description?`<p class="text-sm text-slate-600 dark:text-slate-300 mb-3 whitespace-pre-wrap">${c.description}</p>`:''}
<div class="mt-auto pt-3">
    <div class="bg-slate-50 dark:bg-slate-800 p-2 rounded border dark:border-slate-600 mb-3">
        <div class="text-xs font-bold text-slate-600 dark:text-slate-300 border-b dark:border-slate-600 mb-1 pb-1">${i18n[currentLang].timeLogsLabel}</div>
        ${logsHtml || `<div class="text-[11px] text-slate-400 italic">${i18n[currentLang].noLogs}</div>`}
    </div>
    <div class="flex justify-end"><span class="bg-blue-100 dark:bg-blue-900/50 text-blue-800 dark:text-blue-200 text-xs py-1.5 px-3 rounded font-bold border border-blue-200 dark:border-blue-700">&#9201;&#65039; ${i18n[currentLang].total} ${totalStr}</span></div>
</div>`;
document.getElementById('col-'+c.column).appendChild(el);
});
}

function allowDrop(e){e.preventDefault();}
function drop(e,col){
e.preventDefault();
const id=e.dataTransfer.getData("id");
const card=cards.find(x=>x.id===id);
if(card && card.column!==col){
const colNames = {backlog: i18n[currentLang].optBacklog, desenvolvendo: i18n[currentLang].optDev, concluido: i18n[currentLang].optDone};
card.column=col; saveData(); render(); showToast(`${i18n[currentLang].msgMove} ${colNames[col]}`);
}
}

document.getElementById('cardForm').onsubmit=(e)=>{
e.preventDefault();
const id=document.getElementById('cardId').value;
const t=document.getElementById('title').value; const p=document.getElementById('project').value;
const dt=document.getElementById('date').value; const c=document.getElementById('column').value;
const d=document.getElementById('description').value;

if(id){
const card=cards.find(x=>x.id===id); 
card.title=t; card.project=p; card.date=dt; card.column=c; card.description=d; card.timeLogs=[...tempLogs];
showToast(i18n[currentLang].msgUpd);
}else{
cards.push({id:'c'+Date.now(),title:t,project:p,date:dt,column:c,description:d,timeLogs:[...tempLogs]});
showToast(i18n[currentLang].msgNew);
}
tempLogs=[]; renderLogs(); saveData(); render(); e.target.reset(); document.getElementById('cardId').value='';
};

window.editCard=(id)=>{
const c=cards.find(x=>x.id===id);
document.getElementById('cardId').value=c.id; document.getElementById('title').value=c.title;
document.getElementById('project').value=c.project; document.getElementById('date').value=c.date||'';
document.getElementById('column').value=c.column; document.getElementById('description').value=c.description;
tempLogs = c.timeLogs ? [...c.timeLogs] : []; renderLogs();
window.scrollTo({top:0,behavior:'smooth'});
};
window.delCard=(id)=>{if(confirm(i18n[currentLang].msgDelConfirm)){cards=cards.filter(x=>x.id!==id);saveData();render();showToast(i18n[currentLang].msgDel, 'error');}};
loadData();
</script>
</body>
</html>
'@

$listener=New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)
try{
$listener.Start()
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Servidor rodando na porta $port" -ForegroundColor Green
Write-Host " Pressione CTRL+C para encerrar." -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Cyan
Start-Process $url
while($listener.IsListening){
$ctx=$listener.GetContext()
$req=$ctx.Request
$res=$ctx.Response
if($req.Url.AbsolutePath -eq '/'){
$buf=[System.Text.Encoding]::UTF8.GetBytes($htmlContent)
$res.ContentType="text/html; charset=utf-8"
$res.ContentLength64=$buf.Length
$res.OutputStream.Write($buf,0,$buf.Length)
$res.Close()
}elseif($req.Url.AbsolutePath -eq '/api/data'){
if($req.HttpMethod -eq 'GET'){
$data="[]"
if(Test-Path $jsonFile){$data=Get-Content -Path $jsonFile -Raw -Encoding UTF8}
$buf=[System.Text.Encoding]::UTF8.GetBytes($data)
$res.ContentType="application/json; charset=utf-8"
$res.ContentLength64=$buf.Length
$res.OutputStream.Write($buf,0,$buf.Length)
$res.Close()
}elseif($req.HttpMethod -eq 'POST'){
$rd=New-Object System.IO.StreamReader($req.InputStream,[System.Text.Encoding]::UTF8)
$body=$rd.ReadToEnd()
$rd.Close()
$body | Out-File -FilePath $jsonFile -Encoding UTF8 -Force
$res.StatusCode=200
$res.Close()
}
}else{
$res.StatusCode=404
$res.Close()
}
}
}catch{
Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red
}finally{
if($listener.IsListening){$listener.Stop()}
$listener.Close()
Write-Host "Servidor encerrado com sucesso." -ForegroundColor Green
}
