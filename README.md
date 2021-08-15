# mkiso

Скрипт для создания LiveCD/USB образа дистрибутива. Форк скрипта из Olean Linux.

Использование:

```bash
sudo bash mkiso.sh [путь до директории с дистрибутивом] [название iso-образа]
```

Например:

```bash
sudo bash mkiso.sh /mnt/lin calmira-lx4-1.1.iso
```

## Настройки

Все настройки находятся в файле `/etc/mkiso.conf`. В них перечислены:

- Версия Calmira (параметр `CALMVERSION`);
- Название метки диска (параметр `LABEL`).

Название метки диска не должно включать в себя пробелов. Советуется использовать только буквы (латинские) в верхнем и нижнем регистре.

Параметр `CALMVERSION` - версия дистрибутива. Рекомендуется использовать дефолтное значение, использованное в `/etc/mkiso.conf`, либо в самой программе.

Пример конфигурационного файла:

```bash
# Begin /etc/mkiso.conf

# CALMVERSION - version of Calmira
# LABEL - label of USB/CD

CALMVERSION="1.1"
LABEL="CalmiraLiveCD"

# End /etc/mkiso.sh
```

Если какого-то из перечисленных выше параметров нет, то будут использоваться стандартные значения.
