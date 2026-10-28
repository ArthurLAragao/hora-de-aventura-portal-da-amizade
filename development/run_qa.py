"""Run optional Godot QA outside the playable project's resource tree."""
from pathlib import Path
import argparse,json,subprocess,tempfile,shutil,sys

def main():
    """Stage QA paths in a temporary folder and retain reports outside the game."""
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--project',type=Path,default=Path(__file__).resolve().parent.parent/'jogo')
    parser.add_argument('--godot',required=True)
    parser.add_argument('--output',type=Path,default=Path(tempfile.gettempdir())/'portal-da-amizade-qa')
    parser.add_argument('--resolution',default='1280x720',choices=['1280x720','1152x648'])
    parser.add_argument('test',choices=['verify_journey_1','verify_level_2','verify_final_regions','verify_journey_6','verify_journey_safety','verify_regional_states','verify_menu','verify_pixel_art_finish','verify_feedback234','verify_optimization'])
    args=parser.parse_args();project=args.project.resolve();output=args.output.resolve()
    if not (project/'project.godot').is_file():parser.error('project.godot not found')
    if output.is_relative_to(project):parser.error('QA output must be outside the game project')
    output.mkdir(parents=True,exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='portal-qa-') as temporary:
        qa=Path(temporary)/'qa';shutil.copytree(Path(__file__).resolve().parent/'qa',qa)
        for file in qa.rglob('*'):
            if file.suffix in ['.gd','.tscn','.tres']:
                file.write_text(file.read_text(encoding='utf-8-sig').replace('res://tests/',qa.as_posix()+'/'),encoding='utf-8')
        report=output/(args.test+'.json')
        if report.exists():report=output/(args.test+'-'+str(__import__('time').time_ns())+'.json')
        command=[args.godot,'--path',str(project),'--fixed-fps','60','--audio-driver','Dummy','--script',str(qa/(args.test+'.gd')),'--','--report='+str(report),'--capture-dir='+str(output)]
        if args.resolution=='1280x720':command+=['--resolution=1280x720']
        result=subprocess.run(command,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=240)
        console=result.stdout+result.stderr
        (output/(report.stem+'.log')).write_text(console,encoding='utf-8')
        problems=[line for line in console.splitlines() if 'SCRIPT ERROR' in line or line.startswith(('ERROR:','WARNING:','FAIL','WALK_TIMEOUT'))]
        if args.test=='verify_menu' and result.returncode==0 and 'Menu check failures: 0' in console:
            report.write_text(json.dumps({'failures':0,'checks':[line for line in console.splitlines() if line.startswith('PASS ')]},indent=2),encoding='utf-8')
        ok=result.returncode==0 and report.exists() and not problems
        print(console);print('Report:',report,'Verified:',ok)
        return 0 if ok else 1

if __name__=='__main__':sys.exit(main())
