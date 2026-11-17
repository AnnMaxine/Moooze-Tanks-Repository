import json
from pathlib import Path

nodes=[]
def box(key,text,x,y,w=100,h=34,parent=None,color='white'):
    nodes.append(dict(id=key,text=text,x=x,y=y,w=w,h=h,parent=parent,color=color))
def stack(parent,items,x,y,w=100,h=34,step=48):
    for i,text in enumerate(items): box(parent+'_'+str(i),text,x,y+i*step,w,h,parent)
box('root','Moooze Tanks',732,286,158,40,color='dark')
box('pm','Project Management',220,361,138,40,'root','orange')
box('dev','Project Development',1292,353,142,40,'root','orange')
for key,text,x in [('init','Initiation',100),('plan','Planning',200),('exec','Execution',300),('close','Closing',401)]:
    box(key,text,x,421,79,40,'pm','yellow')
stack('init',['Develop Design\nDocument','Develop Scope\nStatement','Develop Project\nCharter','Develop Team\nBuilding Activity'],100,480,80,40,60)
stack('plan',['Develop Work\nBreakdown\nStructure','Develop\nEstimating\nWorksheet','Develop Gantt\nChart','Develop Alpha\nNarrative','Develop Risk\nRegistry','Develop\nKanban Board'],200,480,79,40,58)
stack('exec',['Manage Change\nLog','Submit Change\nRequest','Maintain Issue\nLog','Maintain\nRequirement\nManagement\nPlan','Submit Scrum-\nWorksheet','Submit Status\nUpdates','Record Meeting\nMinutes','Submit Test Log','Submit Prompt\nLog','Develop Alpha\nDemo','Develop Beta\nDemo'],300,480,80,40,56)
stack('close',['Compile full\ndocumentation\nfor project','Review the\nproject with\nsponsors','Submit project to\nclient/instructor','Conduct Peer\nEvaluation','Develop Lessons\nLearned','Present Finished\nProduct'],401,480,80,40,56)
for key,text,x in [('res','Resources & Assets',975),('screens','Screens',1313),('prog','Programming',1462),('qa','Final Testing and\nQuality Assurance',1806)]:
    box(key,text,x,417,100,40,'dev','yellow')
box('graphics','Graphic Objects',687,490,99,32,'res')
box('audio','Audio Assets',976,490,98,32,'res')
box('training','Training Materials',1136,490,99,32,'res')
box('sprites','Tank Sprites &\nAnimations',590,547,73,36,'graphics')
stack('sprites',['Tank 1 Chassis\nSprite','Tank 2 Chassis\nSprite','Tank 1 Turret\nSprite','Tank 2 Turret\nSprite','Tank Explosion','Tank Shell\nProjectile'],590,601,73,33,46)
box('env','Environment\nObjects',699,546,75,36,'graphics')
stack('env',['Destructible\nWooden Crate\nObstacle','Destructible\nBrick Wall\nObstacle','Indestructible\nSolid\nPerimeter Wall','Indestructible\nConcrete Pillar','Moving Moose\nEntity'],699,599,75,41,54)
box('gui','GUI & Buttons',811,546,75,36,'graphics')
box('buttons','Buttons',821,591,75,28,'gui')
stack('buttons',['Host Game\nButton','Join Game\nButton','Solo Practice\nButton','Controls Button','Help Button','Credits Button','Exit Button'],829,627,76,33,43)
box('guicontrols','GUI Controls',821,931,75,28,'gui')
stack('guicontrols',['Player Life\nCounter UI','Match Score\nCounter UI','Pre-Moose\nHazard Warning\nVisual','Player Health\nCounter'],829,971,76,34,45)
stack('audio',['Background Music','Tank Engine Idle SFX','Tank Engine\nDriving SFX','Cannon Firing SFX','Moose Blast SFX','Moose Roar SFX','Obstacle Destruction\nSFX','Tank Explosion SFX','Match Victory SFX'],993,534,100,32,41)
box('codex','Codex',1146,535,99,20,'training')
stack('codex',['Setup','Training','Developer Instructions\n(agent.md)'],1158,566,98,30,35)
box('godot','Godot',1146,678,99,20,'training')
stack('godot',['Setup','Training'],1158,709,98,24,31)
stack('screens',['Main Menu Screen','Gameplay HUD\nOverlay','Pause Overlay\nScreen','Match Results/\nSummary Screen','Controls Screen','Help Screen'],1327,476,100,40,56)
box('controls','Player Controls',1462,500,99,40,'prog')
stack('controls',['WASD Chassis\nDirectional Movement','WASD Chassis\nSteering Physics','Mouse 360-Degree\nTurret Aiming','Mouse Cannon Firing\nTrigger'],1593,460,100,33,40)
box('mechanics','Game Mechanics',1474,856,99,40,'prog')
stack('mechanics',['Static Perimeter\nCollision Detection','Cover Node Collision\nDetection','Tank Spawning\nMechanism','Moose Wave\nSpawning Mechanism','Area2D Environmental\nHazard Triggers','Match Timer\nMechanism','Score Tracking\nSystem','Life Tracking System','Client-Server\nSocket Connection','Socket Network Data\nFormatting','Health Tracking\nSystem'],1593,654,100,33,40)
stack('qa',['Quality\nControl/Management','Risk Assessment','Risk Management','Testing and Validation','Defect Prevention','Product Reviews'],1806,472,100,40,56)
Path(__file__).with_name('wbs-layout.json').write_text(json.dumps(nodes,indent=2),encoding='utf-8')
print('Editable boxes:',len(nodes))
