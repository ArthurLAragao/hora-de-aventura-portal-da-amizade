# Desenvolvimento opcional

Esta pasta fica fora de `jogo/`. Não é necessária para jogar ou abrir as fases.

- `qa/` e `run_qa.py`: suíte atual; prepara recursos temporários fora do jogo.
- `art_sources/`: matrizes, folhas de revisão, prompts e material de autoria preservado.
- `art_tools/`: ferramentas antigas de preparação, para uma cópia de autoria.
- `archive/legacy_qa/`: testes/salas antigos, não mantidos como validação atual. `verify_checkpoint.gd` pressupõe a antiga hierarquia `Players/Finn`, incompatível com o novo layout; use `verify_journey_safety` e `verify_journey_1`.
- `legacy_mechanisms/`, `unused_code/`: cópias históricas; os componentes de execução estão em `jogo/mechanisms/` e `jogo/scripts/`.

Exemplo: `python development/run_qa.py --project jogo --godot CAMINHO_DO_GODOT verify_journey_6`.

Arquivos históricos foram preservados para consulta, sem serem apresentados como testes atuais aprovados. O jogo não carrega esta pasta.
