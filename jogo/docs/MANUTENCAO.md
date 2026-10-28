# Manutenção e QA externo

## Projeto de execução

Não coloque backups, capturas temporárias, matrizes grandes ou salas de teste dentro de `Assets/`. Mantenha o projeto em Godot 4.7.2. Não remova `.uid`/`.import` pertinentes; a pasta `.godot` é regenerada pelo editor e não deve ir no pacote fonte ou Git.

As cenas principais continuam na raiz. Scripts foram agrupados em `scripts/` e as referências atualizadas, preservando os UIDs existentes. A lista completa de caminhos anteriores/novos está na área externa de evidências da otimização.

## QA fora do jogo

No repositório, `development/qa/` contém a suíte opcional e `development/run_qa.py` prepara seus caminhos em uma pasta temporária externa. Não é necessário restaurar `tests/` no jogo.

Exemplo a partir da raiz do repositório:

```text
python development/run_qa.py --project jogo --godot CAMINHO_DO_GODOT verify_journey_1
python development/run_qa.py --project jogo --godot CAMINHO_DO_GODOT verify_level_2
python development/run_qa.py --project jogo --godot CAMINHO_DO_GODOT verify_final_regions
python development/run_qa.py --project jogo --godot CAMINHO_DO_GODOT verify_journey_6
```

O runner é uma ferramenta de desenvolvimento, não uma dependência do jogo. A primeira abertura do projeto deve importar os recursos/classes normalmente. Resultados e capturas ficam fora da pasta do jogo.

## Arte e autoria

`development/art_sources/` preserva matrizes, folhas de revisão e prompts; `development/art_tools/` preserva scripts de preparação. Essas ferramentas antigas podem pressupor os caminhos originais: use uma cópia de autoria, restaurando somente os recursos necessários, nunca o jogo de entrega como área de geração. PNGs da Fase 5 permanecem em `Assets/02_Environments/05_mirror_tower/` para a próxima integração.

## Evolução segura

1. Faça backup ou commit antes de alterar.
2. Mantenha a física separada da apresentação.
3. Preserve o contrato de cancelamento e recuperação dos mecanismos.
4. Teste os papéis P1/P2 e a fase afetada do início ao fim.
5. Verifique referências e execute as regressões pertinentes antes de publicar.

Os materiais retirados foram arquivados, não descartados. Não tente usar um relatório histórico como prova de funcionamento de uma versão posterior.
