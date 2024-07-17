1. Данный доке запускается только на Linux Ubuntu, Windows WSL, виртуальной машине с Ubuntu на Yandex Cloud или AWS.
2. Для запуска докера необходимо установить Docker Desktop.
3. После установки Docker Desktop необходимо запустить Docker Desktop.
4. Также для Windows необходимо установить WSL.
5. Данный проект необходимо копировать в директорию смотнированную в WSL.
6. Открыть проект можно в DataGrip указав путь к директории проекта в WSL: \\wsl$\Ubuntu\home\user\building-data-warehouse\platform
7. Далее нужно собрать образ командой: docker compose build
8. После сборки образа нужно запустить контейнер: docker compose up -d
9. Иногда могут возникать ошибки при запуске контейнера, в таком случае нужно перезапустить Docker Desktop.
10. Такде может помочь перезапуск WSL командой: wsl --shutdown
11. Также может помочь команда: sudo mount --make-shared /