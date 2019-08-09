# Docker - Dockerfile 指令教學

## FROM
- 基底映像檔，必需是「第一個」指令行，指定這個映像檔要以哪一個Image為基底來建構，格式為 => FROM <image> 或 FROM <image>:<tag>


## MAINTAINER
- 映像檔維護者，把它想成是作者即可，格式為 => MAINTAINER<name>


## LABEL 
- 設定映像檔的Metadata資訊，例如：作者、EMail、映像檔的說明等，格式為 => LABEL <key>=<value> <key>=<value> <key>=<value>
(description="這是LABEL的範例" version="1.0" owner="我是owner")
和 MAINTAINER 相比，建議使用 LABEL 來設定會比較方便，另外，如果要查詢 LABEL 的資訊，則可以下 docker inspect 來查詢


## USER 
- 指定運行Container時的用戶名稱或UID，其格式如下：
(1) USER <user>[:<group>]
(2) USER <UID>[:<gid>]
- 在定義了 USER 後，則 Dockerfile 中的 RUN、CMD、ENTRYPOINT 等指令便會以 USER 指定的用戶來執行，前提條件是該用戶必需是已存在的，否則指定會失敗，範例如下：
RUN groupadd -r tester && useradd -r -g tester tester
指定用戶名稱
USER tester
或使用UID來指定
USER 1000


## ARG
- 設定在建置映像檔時可傳入的參數，即定義變數名稱以及變數的預設值，其格式為：
ARG <name>[=<default value>]
ARG 和 ENV 的功能類似，都可以設定變數，但是 ARG 設定的值是供建置映像檔時使用(搭配docker build指令)，在Container中是無法使用這些變數的，
相反地，ENV的值則可以在Container中存取，例如ARG的定義如下：
ARG Param1
ARG Param2=somevalue
- 建構映像檔案，可利用–build-arg <varname>=<value>來指定參數，例如：
docker build --build-arg Param1=demo -t myimage:v1 .
在上面的例子中，我們在 docker build 中利用 –build-arg <varname>=<value> 參數將 Param1 的值變更為「demo」，而 Param2 的值並沒有指定，所以保留預設值「somevalue」


## WORKDIR
- 設定工作目錄，其格式如下：
WORKDIR /path/to/workdir
- 當設定 WORKDIR 後，Dockerfile 中的 RUN、CMD、ENTRYPOINT、COPY、ADD 等指令就會在該工作目錄下執行，以下是官方的示範：
WORKDIR /a
WORKDIR b
WORKDIR c
RUN pwd
- 在上面的範例中，pwd 最後會在 /a/b/c 目錄下執行，如果目錄不存在，系統會幫忙自動建立


## COPY 
- 複製本地端的檔案/目錄到映像檔的指定位置中，其格式為：
(1) COPY [–chown=<user>:<group>] <src>… <dest> => COPY file1.txt file2.js file3.json ./
(2) COPY [–chown=<user>:<group>] [“<src>”,… “<dest>”] => COPY ["file1.txt", "file2.js", "file3.json" "./"]
- 使用COPY的注意事項：
(1) 指令的來源位置可以多個
(2) 如果目的位置是目錄的話，記得最後要以 / 結尾，例如：/mypath/
(3) 目的位置可以是絕對路徑或者相對於WORKDIR定義值的相對路徑
(4) 若目的位置不存在，會自動建立


## ADD
- 和COPY一樣，可將本地端的檔案/目錄複製到映像檔的指定位置內，其格式為：
(1) ADD [–chown=<user>:<group>] <src>… <dest> => ADD file1.txt file2.js file3.json ./
(2) ADD [–chown=<user>:<group>] [“<src>”,… “<dest>”] => ADD https://www.google.com/demo.gzip $ENV_DEMO_VALUE
- 雖然ADD和CMD功能類似，但有二點最大的不同：
(1) ADD的來源路徑支援URL，也就是說可以加入遠端的檔案，COPY則不支援URL
(2) 若來源檔案是壓縮檔(副檔名為gzip、bzip2、xz)，則使用ADD加入檔案時會自動解壓縮，而COPY不會
- 除非你有自動解壓的需求，不然一般建議會使用「COPY」來加入檔案！


## RUN
- 執行指定的指令，每加一個RUN，就會在基底映像層加上一層資料層，以此類推，一層一層的建構起我們最後想要的映像檔，例如我們可以利用RUN來安裝套件，其格式分為二種：
(1) RUN <command>：以shell的形式執行，Linux的預設是/bin/sh -c，而Windows上的預設環境則是cmd /S /C
(2) RUN ["executable", "param1", "param2"]：以exec的形式執行指令，例如Linux上不想用預設的shell執行指令，
那麼就可以透過 RUN [“/bin/bash”, “-c”, “echo hello”] 指定想要的shell
意思是說exec執行的方式不會使用command shell，所以執行 RUN [ “echo”, “$HOME” ] 這樣的指令列， $HOME 這個變數是不會被替代(填入值)的，也就是直接輸出「$HOME」，
但如果你想要有Shell處理的功能，則可以自行指定shell來達成：RUN [ “sh”, “-c”, “echo $HOME” ]
- 在使用RUN指令時，有以下注意要點：
(1) 如果想要執行的指令很長，可以利用\符號來換行，比較容易閱讀
(2) 使用exec形式執行時，必需使用JSON array的格式，因此，請使用雙引號
(3) 每一個RUN就會新增一層資料層，為了減少不必要的資料層，可以利用&&來串連多個命令


## EXPOSE 
- 宣告在映像檔中預設要使用(對外)的連接埠，格式如下：
(1) EXPOSE <port> [<port>/<protocol>…] => EXPOSE 80/tcp，EXPOSE 80/udp (EXPOSE預設的協定是TCP，但如果不是要TCP的話，可以自行指定)
- 使用EXPOSE所定義的連接埠並不會自動的啟用，而只是做提示的作用而已，要將連接埠啟用需要在執行 docker run 時，搭配 -p 或 -P 的參數來啟用
小寫的 -p 可以自行指定與主機關聯的連接埠 => docker run -p 80:80/tcp -p 80:80/udp demo
大寫的 -P 則會啟用所有EXPOSE所定義的連接埠，並動態(隨機)的關聯到主機的連接埠，例如：EXPOSE 80 可能隨機關聯到主機的 45123 連接埠 => docker run -P demo


## ENV 
- 設定環境變數，支援二種格式：
(1) ENV <key> <value>：Key 後面的第一個空白鍵後會視為 Value
(2) ENV <key>=<value> …：用等於符號來定義，每一組中間以空白鍵隔開，我個人比較喜歡這種形式，不容易搞混 => ENV demoPATH="/var/log" demoVer="1.0"
使用ENV設置環境變數後，在 Dockerfile 中其他的指令就可以利用，之後在建起來的 Container 裡也可以使用該變數
使用環境變數的例子，有沒有用大括號都可以 COPY debug.log ${demoPATH} 或 ADD $demoFile /foo


## VOLUME 
- 建立本機或來自其他容器的掛載點，指令格式如下：
VOLUME [“/data”]
- VOLUME的值可以是JSON的Array格式，也可以是純文字
(1) VOLUME ["/var/log/"]
(2) VOLUME ["/demo1","/demo2"]
(3) VOLUME /var/log
(4) VOLUME /var/log /var/db
- 要特別注意的是使用 VOLUME 來定義掛載點時，是無法指定本機對應的目錄的，對應到哪個目錄是自動產生，我們可以透過 docker inspect 來查詢目錄資訊


## ENTRYPOINT npm start
- 和CMD一樣，用來設定映像檔啟動Container時要執行的指令，但不同的是，ENTRYPOINT一定會被執行，而不會有像CMD覆蓋的情況發生，支援二種格式：
(1) ENTRYPOINT [“executable”, “param1”, “param2”]：exec形式，官方推薦此種方式
(2) ENTRYPOINT command param1 param2：shell的形式
- 使用 ENTRYPOINT 的注意事項：
(1) Dockerfile 中只能有一行 ENTRYPOINT，若有多行 ENTRYPOINT，則只有最後一行會生效
(2) 若在建立 Container 時有帶執行的命令，ENTRYPOINT 的指令不會被覆蓋，也就是一定會執行
(3) 如果想要覆蓋 ENTRYPOINT 的預設值，則在啟動 Container 時，可以加上「–entrypoint」的參數，例如：docker run –entrypoint


## CMD npm start
- 設定映像檔啟動為 Container 時預設要執行的指令，其指令共支援三種格式：
(1) CMD [“executable”,”param1″,”param2″]：exec形式，官方推薦此種方式
(2) CMD [“param1″,”param2”]：適用於有定義 ENTRYPOINT 指令的時候，CMD 中的參數會做為 ENTRYPOINT 的預設參數
(3) CMD command param1 param2：會以shell的形式執行，預設是在「/bin/sh -c」下執行，適合在需要互動的指令時
- 使用CMD的注意事項：
(1) Dockerfile 中只能有一行CMD，若有多行CMD，則只有最後一行會生效
(2) 若在建立 Container 時有帶執行的命令，則CMD的指令會被蓋掉，
例如：執行 docker run <image id> 時，CMD所定義的指令會被執行，但當執行 docker run <image id> bash 時，
- Container 就會執行bash，而原本CMD中定義的值就會覆蓋

## ONBUILD ADD
## ONBUILD RUN
- 若這個映像檔是作為其他映像檔的基底時，便需要定義 ONBUILD 指令，格式為：
ONBUILD [INSTRUCTION]
ONBUILD 後面接的指令在自建的映像檔中不會被執行，只有當這個映像檔是作為其他映像檔的基底時才會被觸發，
- 例如A映像檔的 Dockerfile 定義如下(假設名稱為A-Image)：
...(以上略)
ONBUILD ADD . /home/tmp
ONBUILD mkdir -p /home/demo/docker
...(以下略)
- 此時如果B映像檔是以A映像檔為基底，則A映像檔中的ONBUILD指令就會被觸發，等於是以下指令：
以A映像檔為基底
FROM A-Image
觸發A映像檔ONBUILD的指令，即會自動執行下面二個指令行
下面二行指令不用自己加，Docker會自動去執行，這邊寫出只是方便做說明
ADD . /home/tmp
mkdir -p /home/demo/docker

# 如何使用 Dockerfile ?
- 介紹了那麼多的指令，最終的目的就是利用 Dockerfile 來建立我們自己的映像檔，其指令為 docker build，範例如下：
在目前目錄尋找 Dockerfile 或 dockerfile
docker build -t myimage:v1 .
-t：Name and optionally a tag in the ‘name:tag’ format，指定映像檔名稱、標籤
- 在上面的範例中，是假設 Dockerfile 在當前目錄下，因此會以.結尾，若是在不同目錄，則可以直接接 Dockerfile 所在目錄或用 -f 來指定 Dockerfile 位置，例如：
後面接 Dockerfile 的所在目錄
docker build -t myimage:v2 ./docker
docker build -f /path/to/a/Dockerfile -t myimage:v3 .
用 -f 來指定 Dockerfile 的位置時，後面接的目錄(及其子目錄)需要能夠找到 Dockerfile，否則會出現 context 錯誤
- 小結：Dockerfile裡面的指令也不少，但因篇幅的關係這邊沒有列出所有的指令，但應該也足夠滿足大部分的需求，想要更深入研究的話，建議可以參考官方的文件，但我個人認為最快的學習方法可以自己動手做做看，比較能夠體會每個指令到底有什麼功用

