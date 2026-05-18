$ErrorActionPreference = 'Stop'
$content = [System.IO.File]::ReadAllText('index.html', [System.Text.Encoding]::UTF8)

# 1. Update Tabs
$tabsOld = '<button class="t b" onclick="sINV(2)">В: Долг 100%+33%</button>'
$tabsNew = '<button class="t b" onclick="sINV(2)">В: Долг 100%+33%</button>' + "`n" + '    <button class="t b" onclick="sINV(3)">Г: Возврат 100% → 33/67</button>' + "`n" + '    <div class="sep"></div>' + "`n" + '    <label class="t b" style="display:inline-flex; align-items:center; gap:5px; cursor:pointer;"><input type="checkbox" id="alcCheck" onchange="sAlc(this.checked)" style="accent-color:#CC0000; cursor:pointer; width:12px; height:12px; margin:0;"> 🍷 С алкогольным баром</label>'
$content = $content.Replace($tabsOld, $tabsNew)

# 2. Update JS Constants
$jsOld = 'const INVS=[1,2,3];'
$jsNew = 'const INVS=[1,2,3,4];'
$content = $content.Replace($jsOld, $jsNew)

# 3. Inject new Build Model function before (function(){var S=35000;
$buildFunc = @'
const BASE_OPS = {};
const BFK_ALL = ["N", "B", "O", "I"];
BFK_ALL.forEach(k => {
  let rows = JSON.parse(JSON.stringify(D[k+"_1"]));
  rows.forEach(r => { if(r[12]===70000){ r[12]=35000; r[17]+=35000; } });
  if(k==="O" || k==="I") {
    let trg = k==="O"?3700:3900;
    for(let i=48; i<60; i++){
      let r=rows[i], rt=trg/r[2], nv=Math.round(r[3]*rt);
      r[2]=trg; r[3]=nv; r[4]=Math.round(nv*0.13); r[6]=Math.round(r[6]*rt);
      r[8]=Math.round(nv*0.015); r[9]=Math.round(r[9]*rt); r[10]=Math.round(nv*0.01);
      r[17]=r[3]-r[4]-r[5]-r[6]-r[7]-r[8]-r[9]-r[10]-r[11]-r[12]-r[13]-r[14]-r[15]+r[16];
    }
  }
  BASE_OPS[k] = rows.map(r => r.slice(0, 18));
});

let isAlcohol = false;
function buildModel() {
  const INV_BASE = isAlcohol ? 14000000 : 13000000;
  BFK.forEach(k => {
    let base = JSON.parse(JSON.stringify(BASE_OPS[k]));
    if (isAlcohol) {
      base.forEach(r => {
        let oldRev = r[3];
        let checks = r[1];
        let oldCheck = r[2];
        let multiplier = oldRev / (checks * oldCheck);
        r[2] = oldCheck + 200;
        let newRev = Math.round(checks * r[2] * multiplier);
        r[3] = newRev;
        let cogsDiff = Math.round(newRev * 0.13) - Math.round(oldRev * 0.13);
        let acqDiff = Math.round(newRev * 0.015) - Math.round(oldRev * 0.015);
        let taxDiff = Math.round(newRev * 0.08) - Math.round(oldRev * 0.08);
        let miscDiff = Math.round(newRev * 0.01) - Math.round(oldRev * 0.01);
        r[4] += cogsDiff; r[8] += acqDiff; r[9] += taxDiff; r[10] += miscDiff;
        r[17] = r[17] + (newRev - oldRev) - cogsDiff - acqDiff - taxDiff - miscDiff;
      });
    }

    for(let opt=1; opt<=4; opt++) {
      let rows = JSON.parse(JSON.stringify(base));
      let cumInv = 0, cumMgr = 0, cumIntr = 0;
      let d_rem = (opt===1) ? (INV_BASE * 0.5) : INV_BASE;
      for(let i=0; i<rows.length; i++) {
        let r = rows[i];
        let np = r[17];
        r[18] = (i===0 ? -(INV_BASE - 340000) : rows[i-1][18]) + np;
        let intr = 0; let inv_payout = 0; let mgr_payout = 0;
        
        if (opt===1) {
          intr = Math.round(d_rem * 0.165 / 12);
          if (np <= 0) { d_rem += intr; } 
          else {
            let totalOwed = d_rem + intr;
            let mgrShare = np * 0.5; let invShare = np * 0.5;
            if (mgrShare <= totalOwed) {
               d_rem = totalOwed - mgrShare; inv_payout = np; mgr_payout = 0;
            } else {
               d_rem = 0; inv_payout = invShare + totalOwed; mgr_payout = mgrShare - totalOwed;
            }
          }
        } else if (opt===2) {
          if (np > 0) {
            if (np <= d_rem) { inv_payout = np; d_rem -= np; } 
            else { inv_payout = d_rem + (np - d_rem) * 0.5; mgr_payout = (np - d_rem) * 0.5; d_rem = 0; }
          }
        } else if (opt===3) {
          intr = Math.round(d_rem * 0.165 / 12);
          if (np <= 0) { d_rem += intr; } 
          else {
            let totalOwed = d_rem + intr;
            if (np <= totalOwed) { inv_payout = np; d_rem = totalOwed - np; } 
            else {
              let rem = np - totalOwed;
              inv_payout = Math.round(totalOwed + rem / 3);
              mgr_payout = Math.round(rem * 2 / 3);
              if(inv_payout + mgr_payout !== np) mgr_payout = np - inv_payout;
              d_rem = 0;
            }
          }
        } else if (opt===4) {
          if (np > 0) {
            if (np <= d_rem) { inv_payout = np; d_rem -= np; } 
            else {
              let rem = np - d_rem;
              inv_payout = Math.round(d_rem + rem / 3);
              mgr_payout = Math.round(rem * 2 / 3);
              if(inv_payout + mgr_payout !== np) mgr_payout = np - inv_payout;
              d_rem = 0;
            }
          }
        }
        
        cumInv += inv_payout; cumMgr += mgr_payout; cumIntr += intr;
        r[19] = intr; r[20] = 0; r[21] = d_rem;
        r[22] = inv_payout; r[23] = mgr_payout; r[24] = cumInv; r[25] = cumMgr; r[26] = cumIntr;
      }
      D[k + '_' + opt] = rows;
    }
  });

  for (let k in D) {
    if (!k.includes('_')) continue;
    let lr = D[k][59];
    let m = {};
    m.invT = lr[24]; m.mgrT = lr[25];
    m.roi = 0; m.mult = 0;
    if (m.invT > 0) {
      m.roi = Math.round((m.invT - INV_BASE) / (INV_BASE / 100) * 10) / 10;
      m.mult = Math.round(m.invT / INV_BASE * 100) / 100;
    }
    m.cumIntr = lr[26];
    m.bizVal = Math.max(0, lr[17] * 25);
    
    let invPaid = false, mgrPaid = false;
    m.invP = 'нет дохода'; m.mgrP = 'нет дохода';
    let rows = D[k];
    for (let i=0; i<rows.length; i++) {
      if (!invPaid && rows[i][24] >= INV_BASE) { m.invP = 'Месяц ' + (i+1); invPaid = true; }
      if (!mgrPaid && rows[i][25] > 0) { m.mgrP = 'Месяц ' + (i+1); mgrPaid = true; }
    }
    
    let opt = k.split('_')[1];
    if (opt === '1' || opt === '2') {
      m.invBiz = Math.round(m.bizVal / 2); m.mgrBiz = Math.round(m.bizVal / 2);
    } else {
      m.invBiz = Math.round(m.bizVal / 3); m.mgrBiz = Math.round(m.bizVal * 2 / 3);
    }
    M[k] = m;
  }
}
buildModel();

function sAlc(checked) {
  isAlcohol = checked;
  buildModel();
  let h1 = document.querySelector('.hdr h1');
  if(h1) h1.innerHTML = '🧱 Финмодель — Все расходы <span>| '+(isAlcohol?'14 000 000':'13 000 000')+' руб | 16.5%/год (ключ 14.5%+2%)</span>';
  update();
}

/*
'@

# We find the IIFE and remove it
$iifeSearch = '\(function\(\)\{var S=35000;.*?\n\}\)\(\);'
$content = [Text.RegularExpressions.Regex]::Replace($content, $iifeSearch, $buildFunc, [Text.RegularExpressions.RegexOptions]::Singleline)

# Clean up the opening comment block that was added by @'
$content = $content.Replace("/*`n'@", "")

# Also update DESC and INVN. They might have literal cyrillic. Since we read it, we can replace the known parts.
$descSearch = "16.5%/год. Вся прибыль на погашение. Доли прибыли: Инвестор 33%, Управляющий 67%. Выплата: 6 500 000 \+ проценты."
$descReplace = "16.5%/год. Вся прибыль на погашение. Доли прибыли: Инвестор 33%, Управляющий 67%.', '4':'Г: Капитал без процентов. Возврат 100% прибыли до окупаемости. Далее прибыль делится: 33% инвестору, 67% управляющему."
$content = [Text.RegularExpressions.Regex]::Replace($content, $descSearch, $descReplace)

$invnOld = "Долг 100%+33% доли'"
$invnNew = "Долг 100%+33% доли','4':'Г: Возврат 100% → 33/67'"
$content = $content.Replace($invnOld, $invnNew)

[System.IO.File]::WriteAllText('index.html', $content, [System.Text.Encoding]::UTF8)
Write-Output 'Done!'
