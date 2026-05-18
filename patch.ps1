$content = [IO.File]::ReadAllText('index.html')

$cssSearch = '@keyframes pulse{0%,100%{box-shadow:0 4px 0 #003d7a}50%{box-shadow:0 4px 0 #0077cc}}'
$cssReplace = $cssSearch + "`n" + '#app-wrapper{opacity:0;transform:scale(0.85) translateY(40px);filter:blur(8px);transition:all 1.4s cubic-bezier(0.175,0.885,0.32,1.275);transform-origin:center top;min-height:100vh;}' + "`n" + '#app-wrapper.revealed{opacity:1;transform:scale(1) translateY(0);filter:blur(0);}'
$content = $content.Replace($cssSearch, $cssReplace)

# Replace Body to include App Wrapper
$content = $content -replace '<body>(\r?\n)+<div class="hdr">', "<body>`n<div id=`"app-wrapper`">`n<div class=`"hdr`">"

# Replace closing of wrap to close App Wrapper
$content = $content -replace '<div class="wrap"><div id="tbl"></div></div>(\r?\n)+<script>', "<div class=`"wrap`"><div id=`"tbl`"></div></div>`n</div>`n`n<script>"

# Add script at bottom
$endSearch = 'sBF(0);'
$endReplace = @"
sBF(0);
</script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
<script>
const container=document.createElement('div');container.style.cssText='position:fixed;top:0;left:0;width:100%;height:100%;z-index:-1;pointer-events:none;';document.body.appendChild(container);
const scene=new THREE.Scene();scene.fog=new THREE.FogExp2(0x1a1a1a,0.015);
const camera=new THREE.PerspectiveCamera(60,window.innerWidth/window.innerHeight,0.1,1000);camera.position.z=30;camera.position.y=5;camera.lookAt(0,0,0);
const renderer=new THREE.WebGLRenderer({antialias:true,alpha:true});renderer.setSize(window.innerWidth,window.innerHeight);renderer.setPixelRatio(window.devicePixelRatio);renderer.shadowMap.enabled=true;container.appendChild(renderer.domElement);
const ambLight=new THREE.AmbientLight(0xffffff,0.65);scene.add(ambLight);
const dirLight=new THREE.DirectionalLight(0xffffff,0.8);dirLight.position.set(10,20,15);dirLight.castShadow=true;scene.add(dirLight);
const colors=[0xe3000b,0x0055bf,0xf6d304,0x237841,0xffffff,0xff8c00];
function createLegoBrick(color){const group=new THREE.Group();const mat=new THREE.MeshStandardMaterial({color:color,roughness:0.2,metalness:0.1});const baseGeo=new THREE.BoxGeometry(4,1.2,2);const base=new THREE.Mesh(baseGeo,mat);base.castShadow=true;base.receiveShadow=true;group.add(base);const studGeo=new THREE.CylinderGeometry(0.3,0.3,0.2,16);for(let i=0;i<4;i++){for(let j=0;j<2;j++){const stud=new THREE.Mesh(studGeo,mat);stud.position.set(-1.5+i*1,0.7,-0.5+j*1);stud.castShadow=true;stud.receiveShadow=true;group.add(stud);}}return group;}
const explosionBricks=[];for(let i=0;i<70;i++){const col=colors[Math.floor(Math.random()*colors.length)];const brick=createLegoBrick(col);brick.position.set((Math.random()-0.5)*4,(Math.random()-0.5)*4,(Math.random()-0.5)*4);brick.rotation.set(Math.random()*Math.PI,Math.random()*Math.PI,Math.random()*Math.PI);const speed=15+Math.random()*25;const theta=Math.random()*Math.PI*2;const phi=Math.acos(Math.random()*2-1);brick.userData={vx:speed*Math.sin(phi)*Math.cos(theta),vy:speed*Math.sin(phi)*Math.sin(theta)+10,vz:speed*Math.cos(phi)+15,rx:(Math.random()-0.5)*0.3,ry:(Math.random()-0.5)*0.3,rz:(Math.random()-0.5)*0.3};scene.add(brick);explosionBricks.push(brick);}
const floatingBricks=[];for(let i=0;i<15;i++){const col=colors[Math.floor(Math.random()*colors.length)];const brick=createLegoBrick(col);brick.position.set((Math.random()-0.5)*80,(Math.random()-0.5)*50,-15-Math.random()*25);brick.rotation.set(Math.random()*Math.PI,Math.random()*Math.PI,Math.random()*Math.PI);brick.userData={rx:(Math.random()-0.5)*0.015,ry:(Math.random()-0.5)*0.015,rz:(Math.random()-0.5)*0.015,yBase:brick.position.y,yOff:Math.random()*Math.PI*2,speed:0.5+Math.random()};scene.add(brick);floatingBricks.push(brick);}
const clock=new THREE.Clock();
function animate(){requestAnimationFrame(animate);const dt=Math.min(clock.getDelta(),0.1);const time=clock.getElapsedTime();for(let i=explosionBricks.length-1;i>=0;i--){const b=explosionBricks[i];b.position.x+=b.userData.vx*dt;b.position.y+=b.userData.vy*dt;b.position.z+=b.userData.vz*dt;b.rotation.x+=b.userData.rx;b.rotation.y+=b.userData.ry;b.rotation.z+=b.userData.rz;b.userData.vy-=50*dt;b.userData.vx*=0.97;b.userData.vz*=0.97;if(b.position.y<-40||b.position.z>100){scene.remove(b);explosionBricks.splice(i,1);}}for(const b of floatingBricks){b.rotation.x+=b.userData.rx;b.rotation.y+=b.userData.ry;b.rotation.z+=b.userData.rz;b.position.y=b.userData.yBase+Math.sin(time*b.userData.speed+b.userData.yOff)*3;}renderer.render(scene,camera);}
animate();window.addEventListener('resize',()=>{camera.aspect=window.innerWidth/window.innerHeight;camera.updateProjectionMatrix();renderer.setSize(window.innerWidth,window.innerHeight);});
setTimeout(()=>document.getElementById('app-wrapper').classList.add('revealed'),1200);
"@
$content = $content -replace 'sBF\(0\);(\r?\n)+</script>(\r?\n)+</body>(\r?\n)+</html>', $endReplace

[IO.File]::WriteAllText('index.html', $content)
