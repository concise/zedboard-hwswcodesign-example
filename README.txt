### 操作流程示範 13-min 螢幕錄影 ###

https://www.youtube.com/watch?v=lFkBfxsl93g



### Homework ###

在重現一次課堂上我們示範的 ARM Linux 內一個程式與 FPGA 的 IP core 協作的情境後，
請修改範例程式以 FPGA 1024-bit 蒙哥馬利模乘法器求 A * B * R**-1 % N 值，其中：

R = 2**1040
N = 0xa3954d818a1d0f4edd554761a7bc4bd3ae1d07f5bdd0c60e3fc9184ed02b0d7d796fca442c46c7566738b0d9a257324f0ab5f4e843e6a7c9cfc8bba397cd5d9b19d33a578cca78cc0f8dfe5dc64721365f037d6e64340b3ee10a14974b83b4f7bdd11b5305132e8f75837017762ae4eb992a79a5364c96e135eae9e07013df4d
A = 0x8a5f0ab2e2d32f612c7a36b141f50ab65a258318dfb17c8ffda809f46ce1d6091e987d092ca6ab6d5ff3cf195ed1622f295283b837932253625c6901dc8d1483e6fdc6700c6a42995c828e2f2f0ffc52962fac6503898eb37cc5adb224373bbdceaa424e8745a2cb621995165a4b5c5e1c1aaa6fd7881e24b0e886665543b2ff
B = 0x9ab05a89280104cdef290ee8e8cd9f29419f2fd3231b589a08081107a419de141652bb37cea658a03b31b1f9b5cf614a6035dd4286dbfc4c5e072f6ef81284109c5ced4cde0430d5f49ed8639155dd5be6c7bec7a6cd3f3d9c540919fafb0e227a07e9f7cbf48473173224e677416bfb13370064a95ed1b81c0d617a2317698c

請將這個答案上傳至課程網站。

用 Python 程式語言來講的話，正確答案是那個唯一的 C 值，使得我們可以通過

        assert 0 <= C < N and 0 == (A*B - C*R) % N



### 範例工作環境 ###

    一張 ZedBoard

    一張 SD 卡
        建議至少 2 GB 容量

    一台筆記型電腦
        SD card slot
        USB port
        Wi-Fi connectivity
        硬碟建議至少 128 GB 容量

    一個工作環境
        有電源
        有 Wi-Fi 無線網路 (連線至 CIC license server)

    已經安裝好 x64 Ubuntu 16.04 Desktop

    已經安裝好 Xilinx Vivado & SDK 2016.4

    在 bash shell 裡有 vivado、bootgen、hsi 等三個指令可以用

    在 bash shell 裡有 dtc、git、screen 等指令可以用
    (sudo apt-get install device-tree-compiler git screen)



### 下載檔案 ###

    1.  下載本 git repository

        git clone https://github.com/concise/zedboard-hwswcodesign-example

    2.  下載 git repository "device-tree-xlnx" 並切換版本到 xilinx-v2016.4 標籤

        git clone https://github.com/Xilinx/device-tree-xlnx --branch xilinx-v2016.4 --depth 1

    3.  下載 2016.3-zed-release.tar.xz 或 2016.3-zc706-release.tar.xz (根據你的開發板而定)

        wget http://www.wiki.xilinx.com/file/view/2016.3-zed-release.tar.xz/601464782/2016.3-zed-release.tar.xz
        wget http://www.wiki.xilinx.com/file/view/2016.3-zc706-release.tar.xz/601464760/2016.3-zc706-release.tar.xz

    4.  下載 linaro-vivid-developer-20151215-714.tar.gz

        wget https://releases.linaro.org/ubuntu/images/developer/15.12/linaro-vivid-developer-20151215-714.tar.gz



### 從 mm1024 專案生成 bitstream ###

    請根據你的開發板，使用 microzed 或 zc706 或 zedboard 版本的 TCL 腳本

        cd mm1024
        vivado -mode batch -source generate_system.zedboard.tcl

    根據你的電腦的運算資源，你可能需要等待 5 ~ 30 分鐘
    前述指令結束後，確認新生成的 .bit 檔案與 .hdf 檔案的位置

        find . -name '*.bit' -or -name '*.hdf'



### 將 SD 卡設置為兩個分割區 ###

    假設 SD 卡裝置會被命名為 /dev/mmcblk0

    MBR partition table 劃分兩個分割區：
    第一個分割區 /dev/mmcblk0p1 檔案系統為 FAT32 容量至少 100 MB 可開機
    第二個分割區 /dev/mmcblk0p2 檔案系統為 ext4  容量至少 1 GB

    SD 卡第一個分割區將用來放置開機相關程式
    SD 卡第二個分割區將用來放置完整的 Linux 根目錄檔案系統 (Linaro)



### 可開機 SD 卡製作攻略示意圖 ###

    請參考本 git repo 內的圖檔 bootpartgen-explained.png



### 填入 SD 卡第一個分割區的內容 ###

    請在當前工作目錄下準備以下檔案、子目錄

        device-tree-xlnx/       <= 剛才下載的 git repository
        fpga.bit                <= 剛才用 vivado 生成的檔案
        fpga.hdf                <= 剛才用 vivado 生成的檔案
        fsbl.elf                <= 來自 2016.3-zed-release.tar.xz
        original-devicetree.dtb <= 來自 2016.3-zed-release.tar.xz
        u-boot.elf              <= 來自 2016.3-zed-release.tar.xz
        uImage                  <= 來自 2016.3-zed-release.tar.xz
        uramdisk.image.gz       <= 來自 2016.3-zed-release.tar.xz

    在這個目錄，執行 bootpartgen 腳本

        bash /path/to/bootpartgen

    腳本執行結束後，會產生一個子目錄 bootpart

        cd bootpart

    將這個目錄下的五個檔案複製到 SD 卡的第一個分割區 (假設 /dev/mmcblk0p1 被掛載到 /mnt/BOOT)

        sudo cp BOOT.BIN devicetree.dtb uEnv.txt uImage uramdisk.image.gz /mnt/BOOT
        sync



### 填入 SD 卡第二個分割區的內容 (此步驟只需要做一次) ###

    假設 /dev/mmcblk0p2 被掛載到 /mnt/LINARO

        sudo tar xpf linaro-vivid-developer-20151215-714.tar.gz --strip-components=1 -C /mnt/LINARO
        sync

    將測試程式複製到 SD 卡上

        sudo cp setclock test.c /mnt/LINARO/root
        sync



### 開機進入 Linaro Linux (based on Ubuntu 15.04) ###

    設定跳線，使 ZedBoard 以 SD 卡開機，連接 UART USB 線至工作電腦

    假設該裝置被命名為 /dev/ttyACM0
    使用 GNU Screen 以 115200 baudrate 連線到 UART serial console

        sudo screen /dev/ttyACM0 115200

    註：常用 GNU Screen 鍵盤綁定

        ^A k    離開
        ^A a    送出 ^A 字元
        ^A C    清除畫面

    有時候，遇到 UART serial console 不正常顯示的狀況，只要多 echo 幾次，搭配 reset 就可以搞定

    UART serial console 預設會直接進入 root 的 bash shell



### 設定時脈，編譯並執行測試程式 ###

    bash setclock

    gcc test.c
    ./a.out



### (optional) 重置 U-Boot 環境變數 ###

    進入 U-Boot 的指令列

        env default -a
        env save
        reset






### 一些檔案連結與 MD5 雜湊值 ###

ubuntu-16.04.1-desktop-amd64.iso
    SIZE = 1513308160
    MD5 = 17643c29e3c4609818f26becf76d29a3
    URL = http://releases.ubuntu.com/xenial/ubuntu-16.04.1-desktop-amd64.iso

----------------------------------------------------------------

Xilinx_Vivado_SDK_2016.4_1215_1.tar.gz
    SIZE = 22071293967
    MD5 = 4a21b34b4105fe31893b572d14a1df48
    URL = https://www.xilinx.com/support/download.html

----------------------------------------------------------------

2016.3-zed-release.tar.xz
    SIZE = 45967360
    MD5 = e3a7c86a4621bcbaf4d6cdc6a26ee86d
    URL = http://www.wiki.xilinx.com/file/view/2016.3-zed-release.tar.xz/601464782/2016.3-zed-release.tar.xz

----------------------------------------------------------------

2016.3-zc706-release.tar.xz
    SIZE = 55592960
    MD5 = 7218245f287998d7f335844a6ec57580
    URL = http://www.wiki.xilinx.com/file/view/2016.3-zc706-release.tar.xz/601464760/2016.3-zc706-release.tar.xz

----------------------------------------------------------------

xilinx-v2016.4.zip
    SIZE = 196485
    MD5 = 79538621dffeceb600fa56a3bc4b7790
    URL = https://github.com/Xilinx/device-tree-xlnx/archive/xilinx-v2016.4.zip

----------------------------------------------------------------

linaro-vivid-developer-20151215-714.tar.gz
    SIZE = 233649127
    MD5 = bd19b93bde4fba93bdeea2451276dce2
    URL = https://releases.linaro.org/ubuntu/images/developer/15.12/linaro-vivid-developer-20151215-714.tar.gz
