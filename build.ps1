$backup = Get-Content backup_index.html -Raw -Encoding UTF8
$scriptStart = $backup.IndexOf('<script>') + 8
$scriptEnd = $backup.IndexOf('</script>')
$jsLogic = $backup.Substring($scriptStart, $scriptEnd - $scriptStart)

# Strip out any old initialization if present so we can control it
$jsLogic = $jsLogic -replace 'sBF\(0\);', ''

$newHtml = @"
<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Premium Hookah Project</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;700;900&display=swap');

:root {
  --bg: #050505;
  --fg: #f4f4f4;
  --accent: #ccff00;
  --accent2: #ff2a2a;
  --card-bg: #111111;
  --border: #222222;
}

* { box-sizing: border-box; margin: 0; padding: 0; }
body {
  font-family: 'Inter', sans-serif;
  background: var(--bg); color: var(--fg);
  overflow-x: hidden;
}

/* --- LOADER: WALKING LEGO SHOES --- */
#loader-overlay {
  position: fixed; top: 0; left: 0; width: 100vw; height: 100vh;
  background: var(--bg); z-index: 9999;
  display: flex; justify-content: center; align-items: center;
  perspective: 800px;
  transition: opacity 0.8s ease-in-out;
}
.shoe-container {
  position: relative; width: 200px; height: 200px;
  transform-style: preserve-3d;
  transform: rotateX(20deg) rotateY(-20deg);
}
.shoe {
  position: absolute; width: 80px; height: 40px;
  background: var(--accent2); border-radius: 8px;
  box-shadow: inset -5px -5px 15px rgba(0,0,0,0.4), 0 15px 25px rgba(0,0,0,0.8);
  /* Studs */
}
.shoe::before {
  content: ''; position: absolute; top: -10px; left: 10px;
  width: 20px; height: 10px; background: var(--accent2); border-radius: 3px;
  box-shadow: 40px 0 0 var(--accent2), inset -2px -2px 5px rgba(0,0,0,0.3);
}
.shoe-left { left: 0; top: 80px; animation: walkLeft 1.5s infinite linear; z-index: 2; }
.shoe-right { left: 100px; top: 80px; animation: walkRight 1.5s infinite linear; animation-delay: 0.75s; z-index: 1; }

@keyframes walkLeft {
  0% { transform: translateZ(0) translateY(0) scale(1); z-index:2; }
  25% { transform: translateZ(60px) translateY(-40px) scale(1.1); z-index:3; }
  50% { transform: translateZ(120px) translateY(0) scale(1.2); z-index:2; }
  75% { transform: translateZ(60px) translateY(0) scale(1.1); z-index:1; }
  100% { transform: translateZ(0) translateY(0) scale(1); z-index:1; }
}
@keyframes walkRight {
  0% { transform: translateZ(0) translateY(0) scale(1); z-index:1; }
  25% { transform: translateZ(60px) translateY(-40px) scale(1.1); z-index:3; }
  50% { transform: translateZ(120px) translateY(0) scale(1.2); z-index:2; }
  75% { transform: translateZ(60px) translateY(0) scale(1.1); z-index:1; }
  100% { transform: translateZ(0) translateY(0) scale(1); z-index:1; }
}
.shoe-smash {
  animation: smashScreen 1.2s forwards cubic-bezier(0.7, 0, 0.2, 1) !important;
}
@keyframes smashScreen {
  0% { transform: translateZ(120px) translateY(0) scale(1.2); }
  100% { transform: translateZ(1000px) translateY(100px) scale(50); opacity: 0; }
}

/* --- MAIN LAYOUT --- */
#app-wrapper {
  opacity: 0; transform: translateY(60px);
  transition: opacity 1.2s cubic-bezier(0.16, 1, 0.3, 1), transform 1.2s cubic-bezier(0.16, 1, 0.3, 1);
  padding-bottom: 100px;
}
#app-wrapper.revealed {
  opacity: 1; transform: translateY(0);
}

.container { max-width: 1400px; margin: 0 auto; padding: 0 5vw; }
section { padding: 8rem 0; position: relative; }

/* Typography */
h1 { font-size: clamp(3rem, 6vw, 6.5rem); font-weight: 900; line-height: 1.05; letter-spacing: -0.04em; text-transform: uppercase; margin-bottom: 2rem; }
h2 { font-size: clamp(2.5rem, 4vw, 4rem); font-weight: 900; line-height: 1.1; letter-spacing: -0.03em; margin-bottom: 3rem; text-transform: uppercase; }
h3 { font-size: 1.8rem; font-weight: 700; margin-bottom: 1rem; color: #fff; }
p { font-size: 1.25rem; line-height: 1.6; color: #a0a0a0; margin-bottom: 1.5rem; }
.text-accent { color: var(--accent); }
.text-red { color: var(--accent2); }

/* Decorative Elements */
.blur-blob { position: absolute; border-radius: 50%; filter: blur(100px); z-index: -1; opacity: 0.15; }
.blob-1 { background: var(--accent); width: 600px; height: 600px; top: -200px; right: -200px; }
.blob-2 { background: var(--accent2); width: 500px; height: 500px; bottom: 20%; left: -200px; }

/* Ticker */
.ticker-container {
  width: 100vw; margin-left: -5vw; overflow: hidden; background: var(--accent); color: #000;
  padding: 1.5rem 0; transform: rotate(-2deg) scale(1.05);
  box-shadow: 0 20px 40px rgba(204, 255, 0, 0.1);
  margin-top: 4rem; margin-bottom: 4rem;
}
.ticker-wrapper { display: flex; width: max-content; animation: tickerScroll 25s linear infinite; }
.ticker-item { font-size: 2rem; font-weight: 900; text-transform: uppercase; padding: 0 3rem; white-space: nowrap; }
@keyframes tickerScroll { to { transform: translateX(-50%); } }

/* Cards & Grids */
.grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 4rem; align-items: stretch; }
@media(max-width: 900px){ .grid-2 { grid-template-columns: 1fr; } }

.glass-card {
  background: rgba(17, 17, 17, 0.6); backdrop-filter: blur(16px);
  border: 1px solid var(--border); border-radius: 24px;
  padding: 3rem; transition: transform 0.4s ease, border-color 0.4s ease;
  position: relative; overflow: hidden;
}
.glass-card:hover { transform: translateY(-10px); border-color: rgba(204, 255, 0, 0.3); }

.stat-number { font-size: 4rem; font-weight: 900; color: var(--accent); line-height: 1; margin-bottom: 1rem; }
.stat-number.red { color: var(--accent2); }

/* Images */
.img-wrapper { border-radius: 24px; overflow: hidden; border: 1px solid var(--border); aspect-ratio: 4/3; }
.img-wrapper img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.6s; }
.img-wrapper:hover img { transform: scale(1.05); }

/* Financial Table Styles overrides */
.fin-section { background: var(--card-bg); border-radius: 24px; padding: 3rem; border: 1px solid var(--border); }
.tabs { display: flex; flex-wrap: wrap; gap: 1rem; margin-bottom: 2rem; }
.t { background: transparent; color: #fff; border: 1px solid var(--border); padding: 1rem 2rem; border-radius: 100px; font-size: 1.1rem; font-weight: 700; cursor: pointer; transition: all 0.3s; }
.t:hover { border-color: var(--accent); }
.t.a { background: var(--accent); color: #000; border-color: var(--accent); }
.kpis { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; margin-bottom: 3rem; }
.kpi { background: rgba(0,0,0,0.4); padding: 1.5rem; border-radius: 16px; border: 1px solid var(--border); }
.kpi b { display: block; font-size: 2rem; color: #fff; margin-bottom: 0.5rem; }
.kpi span { color: #888; font-size: 0.9rem; text-transform: uppercase; font-weight: 700; }
.wrap { overflow-x: auto; border-radius: 12px; border: 1px solid var(--border); background: #0a0a0a; }
table { width: 100%; border-collapse: collapse; text-align: right; font-variant-numeric: tabular-nums; white-space: nowrap; }
th, td { padding: 1rem; border-bottom: 1px solid var(--border); }
th { color: #666; font-size: 0.8rem; text-transform: uppercase; text-align: right; background: #111; position: sticky; top: 0; }
td:first-child, th:first-child { text-align: left; position: sticky; left: 0; background: #111; z-index: 10; font-weight: 500; color: #eee; }
tr:hover td { background: #1a1a1a; }
.desc { margin-bottom: 2rem; font-size: 1.2rem; color: var(--accent); font-weight: 500; }
</style>
</head>
<body>

<!-- LOADER -->
<div id="loader-overlay">
  <div class="shoe-container">
    <div class="shoe shoe-left" id="s-left"></div>
    <div class="shoe shoe-right" id="s-right"></div>
  </div>
</div>

<main id="app-wrapper">
  
  <!-- HERO SECTION -->
  <section class="container" style="padding-top: 15vh; min-height: 90vh;">
    <div class="blur-blob blob-1"></div>
    <div style="max-width: 1000px; position: relative; z-index: 10;">
      <h1>Мы не тупо забиваем кальяны.<br><span class="text-accent">Мы создаем атмосферу.</span></h1>
      <p style="font-size: 1.5rem; max-width: 700px; margin-top: 2rem;">Премиальный подход, глубокое понимание физики курения и комьюнити, в которое гости возвращаются снова и снова. Наши заведения на 80% состоят из постоянных гостей.</p>
    </div>
  </section>

  <!-- TICKER -->
  <div class="ticker-container">
    <div class="ticker-wrapper">
      <div class="ticker-item">Keidj 10.0M+ ₽</div><div class="ticker-item">✦</div>
      <div class="ticker-item">Tulum 9.0M+ ₽</div><div class="ticker-item">✦</div>
      <div class="ticker-item">HP Wild 10.0M+ ₽</div><div class="ticker-item">✦</div>
      <div class="ticker-item">HP Baza 4.8M+ ₽</div><div class="ticker-item">✦</div>
      <div class="ticker-item">Ostrov Озёрная 4.2M+ ₽</div><div class="ticker-item">✦</div>
      <div class="ticker-item">HP Lago 4.5M+ ₽</div><div class="ticker-item">✦</div>
      <!-- Duplicate -->
      <div class="ticker-item">Keidj 10.0M+ ₽</div><div class="ticker-item">✦</div>
      <div class="ticker-item">Tulum 9.0M+ ₽</div><div class="ticker-item">✦</div>
      <div class="ticker-item">HP Wild 10.0M+ ₽</div><div class="ticker-item">✦</div>
      <div class="ticker-item">HP Baza 4.8M+ ₽</div><div class="ticker-item">✦</div>
      <div class="ticker-item">Ostrov Озёрная 4.2M+ ₽</div><div class="ticker-item">✦</div>
      <div class="ticker-item">HP Lago 4.5M+ ₽</div><div class="ticker-item">✦</div>
    </div>
  </div>

  <!-- COMPETITOR ANALYSIS -->
  <section class="container">
    <h2>Анализ рынка</h2>
    <div class="grid-2">
      <div class="glass-card">
        <h3>Локация: Очаково-Матвеевское</h3>
        <p>Плотность населения — <strong>160 000 человек</strong>. Несмотря на огромный спрос, в шаговой доступности находится лишь один серьезный конкурент.</p>
        
        <div style="background: rgba(255,42,42,0.1); padding: 1.5rem; border-left: 4px solid var(--accent2); margin-top: 2rem; border-radius: 0 12px 12px 0;">
          <h3 style="color: var(--accent2);">Ostrov Нежинская</h3>
          <p style="margin-bottom: 0;">Дизайн морально устарел, не отвечает запросам современного гостя. Качество кальянов и сервис оставляют желать лучшего. Но даже при этом они делают выручку более <strong>4.000.000 ₽</strong>.</p>
        </div>
      </div>
      
      <div style="display: flex; flex-direction: column; gap: 2rem;">
        <div class="glass-card" style="flex: 1; display: flex; flex-direction: column; justify-content: center;">
          <p style="margin-bottom: 0.5rem; text-transform: uppercase; font-weight: 700; letter-spacing: 1px;">Потенциал роста с нами</p>
          <div class="stat-number">+35%</div>
          <p style="margin-bottom: 0;">За счет премиального качества, правильной посадки и агрессивного маркетинга.</p>
        </div>
        <div class="glass-card" style="flex: 1; display: flex; flex-direction: column; justify-content: center; border-color: var(--accent);">
          <p style="margin-bottom: 0.5rem; text-transform: uppercase; font-weight: 700; letter-spacing: 1px;">Целевая выручка</p>
          <div class="stat-number" style="color: #fff;">5 500 000 ₽</div>
          <p style="margin-bottom: 0; color: var(--accent);">Ожидаемый показатель после выхода на целевые мощности.</p>
        </div>
      </div>
    </div>
  </section>

  <!-- ADVANTAGES -->
  <section class="container">
    <div class="blur-blob blob-2"></div>
    <h2>Чем будем бить конкурентов?</h2>
    
    <div class="grid-2" style="margin-bottom: 4rem;">
      <div class="glass-card">
        <div class="stat-number red">50.000+</div>
        <h3>Забитых чаш опыта</h3>
        <p>Мы досконально изучили физику курения и методы контроля температуры. Это не просто слова, это математика роста:</p>
        
        <div style="margin-top: 2rem; background: #0a0a0a; padding: 1.5rem; border-radius: 12px; border: 1px solid #222;">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; padding-bottom: 1rem; border-bottom: 1px solid #222;">
            <div>
              <strong style="color: #fff; display: block; margin-bottom: 0.2rem;">HP BAZA (18 мес)</strong>
              <span style="color: #666; font-size: 0.9rem;">Индексация цены без потери трафика</span>
            </div>
            <div style="text-align: right;">
              <span style="color: var(--accent2); text-decoration: line-through; margin-right: 0.5rem;">28</span>
              <strong style="color: var(--accent); font-size: 1.2rem;">55 шт/день</strong>
              <div style="color: #fff; margin-top: 0.2rem;">1.4М → 4.55М ₽</div>
            </div>
          </div>
          
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <div>
              <strong style="color: #fff; display: block; margin-bottom: 0.2rem;">Мята Lounge (12 мес)</strong>
              <span style="color: #666; font-size: 0.9rem;">Рост в готовом заведении</span>
            </div>
            <div style="text-align: right;">
              <span style="color: var(--accent2); text-decoration: line-through; margin-right: 0.5rem;">20</span>
              <strong style="color: var(--accent); font-size: 1.2rem;">35 шт/день</strong>
              <div style="color: #fff; margin-top: 0.2rem;">36К → 68К ₽ / день</div>
            </div>
          </div>
        </div>
      </div>
      
      <div class="img-wrapper">
        <img src="https://images.unsplash.com/photo-1608678880650-7ee4f1e564bd?auto=format&fit=crop&w=800&q=80" alt="Hookah Quality">
      </div>
    </div>
    
    <div class="grid-2">
      <div class="img-wrapper">
        <img src="https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80" alt="Atmosphere">
      </div>
      
      <div class="glass-card">
        <div class="stat-number">80%</div>
        <h3>Постоянных гостей</h3>
        <p>Гости ищут не только дым. Они ищут комьюнити, место для общения, безопасности и комфорта. Мы выстраиваем искренний сервис, где каждый гость чувствует себя частью чего-то большего.</p>
        <p>Именно эта атмосфера заставляет их возвращаться снова и снова, формируя стабильное и защищенное от конкуренции ядро выручки.</p>
      </div>
    </div>
  </section>
  
  <!-- TEAM -->
  <section class="container">
    <h2>Команда проекта</h2>
    <div class="grid-2" style="grid-template-columns: repeat(3, 1fr);">
      <div class="glass-card" style="text-align: center;">
        <div style="width: 120px; height: 120px; border-radius: 50%; background: #222; margin: 0 auto 1.5rem; overflow: hidden; border: 2px solid var(--accent);">
           <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80" style="width: 100%; height: 100%; object-fit: cover;">
        </div>
        <h3>Операционный директор</h3>
        <p style="font-size: 1rem;">Экспертиза в построении сервиса и масштабировании процессов. Контроль качества на всех этапах.</p>
      </div>
      <div class="glass-card" style="text-align: center;">
        <div style="width: 120px; height: 120px; border-radius: 50%; background: #222; margin: 0 auto 1.5rem; overflow: hidden; border: 2px solid var(--accent);">
           <img src="https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=300&q=80" style="width: 100%; height: 100%; object-fit: cover;">
        </div>
        <h3>Шеф-мастер</h3>
        <p style="font-size: 1rem;">50.000+ забитых чаш. Авторские методики контроля температуры и работы с премиальными табаками.</p>
      </div>
      <div class="glass-card" style="text-align: center;">
        <div style="width: 120px; height: 120px; border-radius: 50%; background: #222; margin: 0 auto 1.5rem; overflow: hidden; border: 2px solid var(--accent);">
           <img src="https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=300&q=80" style="width: 100%; height: 100%; object-fit: cover;">
        </div>
        <h3>Арт-директор</h3>
        <p style="font-size: 1rem;">Создание уникальной атмосферы, музыкального формата и визуального кода заведения.</p>
      </div>
    </div>
  </section>

  <!-- FINANCIAL MODEL -->
  <section class="container fin-section">
    <h2 style="margin-bottom: 2rem; font-size: 3rem;">Финансовые расчеты</h2>
    <div class="tabs">
      <button class="t a" onclick="sBF(0)">Базовый сценарий</button>
      <button class="t"   onclick="sBF(1)">Оптимистичный сценарий</button>
      <button class="t"   onclick="sBF(2)">Идеальный сценарий</button>
    </div>
    <div class="desc" id="desc"></div>
    <div class="kpis" id="kpis"></div>
    <div class="wrap"><div id="tbl"></div></div>
  </section>

</main>

<script>
// LOADER ANIMATION LOGIC
window.addEventListener('load', () => {
  setTimeout(() => {
    const lShoe = document.getElementById('s-left');
    const rShoe = document.getElementById('s-right');
    
    // Stop walk animation and trigger smash
    lShoe.style.animation = 'none';
    rShoe.style.animation = 'none';
    rShoe.style.display = 'none'; // hide one
    
    lShoe.classList.add('shoe-smash');
    
    setTimeout(() => {
      document.getElementById('loader-overlay').style.opacity = '0';
      document.getElementById('app-wrapper').classList.add('revealed');
      
      setTimeout(() => {
        document.getElementById('loader-overlay').style.display = 'none';
      }, 800);
    }, 800); // trigger reveal as the shoe covers the screen
    
  }, 2500); // initial walking time
});

// ==========================================
// ORIGINAL FINANCIAL MODEL JAVASCRIPT
// ==========================================
</script>
</body>
</html>
"@

$newHtml = $newHtml.Replace('// ==========================================
// ORIGINAL FINANCIAL MODEL JAVASCRIPT
// ==========================================', $jsLogic + "`n`nsBF(0);")

[IO.File]::WriteAllText('index.html', $newHtml, [System.Text.Encoding]::UTF8)
Write-Host "New landing page built successfully."
