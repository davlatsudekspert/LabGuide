# Video qo‘llanmalar — chiqarilgan fayllar

**Yorliq: ovozsiz, subtitrli ekran yozuvi — diktorsiz.** Har video — ilovaning haqiqiy ekranlari
(widget test render, serversiz, haqiqiy kontent) dan yig‘ilgan; ovoz yo‘q, diktor yo‘q (TTS vositasi
yo‘q). Subtitrlar kadrga yozilgan (burned-in) va alohida SRT/VTT fayl sifatida ham bor.

Fayllar repoga qo‘shilmaydi: `build/video_out/` (gitignore). Qayta yig‘ish — `docs/video/PLAN.md`.
Bu jadval `python3 tool/video/report.py` bilan ffprobe va sha256 orqali o‘lchab yozilgan.

| Fayl | Til | Davomiylik | O‘lcham | Kodek, fps | Audio | Hajm | sha256 |
|---|---|---|---|---|---|---|---|
| `01_kalibrlash_uz.mp4` | uz | 45.5 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.30 MB | `4a3b91c806a57dbc602925e5e33f5d30abf2805f639ed754310dc113355e0dd4` |
| `01_kalibrlash_ru.mp4` | ru | 45.5 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.34 MB | `484e4a25dfc6549f9c906d50757ca1d5743e1d174d7106a0b257dcf94dcd8525` |
| `01_kalibrlash_en.mp4` | en | 45.5 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.23 MB | `81c2a817519580aba8ee32fae96bd8da967c064bfec1499a4e833c01a4613639` |
| `02_sifat_nazorati_uz.mp4` | uz | 46.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.28 MB | `55c01847c66d112b9d65b62915aa73429016ad5ce9149fdaffa9fad33a4f373d` |
| `02_sifat_nazorati_ru.mp4` | ru | 46.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.32 MB | `831502aaae90c75dfadae76700e80c9968a333e552f5870d4086bf42e8079e2c` |
| `02_sifat_nazorati_en.mp4` | en | 46.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.21 MB | `136663858e2135648c8084ba132bc658b09b3e0aa3e697856f99ac65a64b4401` |
| `03_preanalitika_uz.mp4` | uz | 31.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 0.97 MB | `cbefd28a146393386a7e9a90a2b3f8c3468c7f7cd254cd58d0bfceba82e2ad88` |
| `03_preanalitika_ru.mp4` | ru | 31.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.03 MB | `121b6ca0fc9caf2dc2466d71ce684f632bedea2ae08c61b1233939ea7e66bc1a` |
| `03_preanalitika_en.mp4` | en | 31.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 0.95 MB | `9230042fed41dab22d4f5f4063965c92d050b734191d2beb52c2556139671b2b` |
| `04_kalkulyatorlar_uz.mp4` | uz | 33.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 0.98 MB | `8df423b3bbc237043a7e1d604545955b86e1e80aaec9b2b0e0b7d81bfbdc4ede` |
| `04_kalkulyatorlar_ru.mp4` | ru | 33.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.01 MB | `05828149272dfc35ec24142ad30ed52437253770defb76bf7ca06a92f6da327d` |
| `04_kalkulyatorlar_en.mp4` | en | 33.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 0.94 MB | `53001b6497be923cad7d87e019f47554b934b5ec7ef45c025d44a6e2fb1a414a` |
| `05_apparatlar_uz.mp4` | uz | 47.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.48 MB | `7a44a8a6562575f9fb4f738b8f79db3d6b47ecc4eaa25627c6c35d52b994861f` |
| `05_apparatlar_ru.mp4` | ru | 47.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.53 MB | `9f84449ee03ac50885b043ce31ca1197527bd8044936ec58e73a425d9be89d7e` |
| `05_apparatlar_en.mp4` | en | 47.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.42 MB | `a4296f233564b55aa527c966ca220a4f86d0436d099e1866f2eb2db4192fdc3f` |
| `06_mikroskopiya_uz.mp4` | uz | 43.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.25 MB | `2a181ac935955c28e1190d3d23d9db1a40aef14a2970fdfd84f8bf5d84d3b31d` |
| `06_mikroskopiya_ru.mp4` | ru | 43.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.31 MB | `8342b263c25c9205cc11e3d067801ab0b5cf1d0a5162d02059977972e5303761` |
| `06_mikroskopiya_en.mp4` | en | 43.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.31 MB | `34932338e22b2f245e8c2f6c62670c69b108552ae60c089b5f35f090f0523b5f` |
| `07_najas_parazitologiya_uz.mp4` | uz | 41.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.39 MB | `418ce51262a4640a97b217d0c336503bd84eeaa2adaeca40f13db9a581edb2f3` |
| `07_najas_parazitologiya_ru.mp4` | ru | 41.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.43 MB | `e850ada13914539f14baf8a08e98ea35aa0d70ffc0a37286231de6bb6f2e5dce` |
| `07_najas_parazitologiya_en.mp4` | en | 41.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.42 MB | `4a860bf77f2e44c96d319d780b4f5250c4a0f6806ebba041bbdcd8f7e969dba7` |
| `08_bilim_baholash_uz.mp4` | uz | 59.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.54 MB | `bc36f70168e060110e5433a26dda04ec3f264c2d1308baec58a56216ff4c6c0b` |
| `08_bilim_baholash_ru.mp4` | ru | 64.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.86 MB | `994744768278698482c2f241c0ce4d14f6a40eb301bc189777a2794e615ae984` |
| `08_bilim_baholash_en.mp4` | en | 64.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.80 MB | `357c20429349d65d37ba44b97b6093857ceecec7e03684302658d82acf11bce3` |
| `09_testlar_natijalar_uz.mp4` | uz | 46.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.40 MB | `3654837ff0ff94f7d7c13bb956fd2d98f7a69ca31d35cccbdab8e02114bafc0e` |
| `09_testlar_natijalar_ru.mp4` | ru | 46.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.41 MB | `0a34d32e6775c1c1d97edcea879e6f6562aa454bdd28548f9bbb6d081bade5e6` |
| `09_testlar_natijalar_en.mp4` | en | 46.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.29 MB | `98ab87ead1dbacd95065b8d813a7f28d6154f41bbac15b978c65484b3cb5e747` |
| `10_boshqa_funksiyalar_uz.mp4` | uz | 56.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.82 MB | `ecc22bce0ef5966a28252a524f0e0b645501c787eae54486b0e037b88de4c63a` |
| `10_boshqa_funksiyalar_ru.mp4` | ru | 56.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.81 MB | `6adbda76f85616be0c45809c77949af8ddfefe13c77b2ac74b5bd22236712ddd` |
| `10_boshqa_funksiyalar_en.mp4` | en | 56.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.78 MB | `a3fee6b34a7e8b49270affdb3f562d8227252cd99ee6786448353bdd0a256ef6` |

Jami: 30 ta MP4, 40.8 MB.

## Subtitr fayllari (SRT / VTT)

| Fayl | Til | Hajm | sha256 |
|---|---|---|---|
| `01_kalibrlash_uz.srt` | uz | 1055 B | `fac07a0fdf3698c5d2ed20affea45878587cca54baa981b73e28a317bb174817` |
| `01_kalibrlash_uz.vtt` | uz | 1063 B | `0a8ea02f7bdb1ecd2a22aa18d70668dfc3b094c1bd29680ba4194acfd0f8f386` |
| `01_kalibrlash_ru.srt` | ru | 1547 B | `a007e2c9299be22c02be84a80a194c6945012e8a22c99b682a392d76f6b638b6` |
| `01_kalibrlash_ru.vtt` | ru | 1555 B | `4c8671fb8d77ada049f5ca497a2dca025e08df33e74b39e84601722d2d5d7bfe` |
| `01_kalibrlash_en.srt` | en | 1046 B | `f4ec3f815851767e769542bb420215351baeb304fc7f84d0efd1d811f1852caf` |
| `01_kalibrlash_en.vtt` | en | 1054 B | `6be0dcdc39a642b1e2dc44ba4292012151111467fe4802cde489acc12d321f0b` |
| `02_sifat_nazorati_uz.srt` | uz | 1076 B | `cbda214c9bde6e30949a3e80e1134b5a8cdf3f453011ac04a322f340c1b16509` |
| `02_sifat_nazorati_uz.vtt` | uz | 1084 B | `f3c5396f52ff88aac96c0e2fce8ebd89fcd7bdb9c0aa0266d583206ff2aa34ab` |
| `02_sifat_nazorati_ru.srt` | ru | 1566 B | `ce44f7e5480d042ae6cf25ebf5be1906da28db2b9e248b2046345e357d7e75a8` |
| `02_sifat_nazorati_ru.vtt` | ru | 1574 B | `b57aa0332dad5e7b2ced17793a1ea66d6a18457190f59f692d182656693c02b8` |
| `02_sifat_nazorati_en.srt` | en | 1032 B | `2e544d1c63f01bb5555e116805e26b95b47b000d4d37212c23ea513ece2d61b7` |
| `02_sifat_nazorati_en.vtt` | en | 1040 B | `a246c95efbec70acae522e2c7243b21bae234a6203cab3dc4a4c00eb9413c99e` |
| `03_preanalitika_uz.srt` | uz | 704 B | `cbe3156d9a0a85ead88aa496e7831d0be9702f8727b527f2c4e421269c1894dc` |
| `03_preanalitika_uz.vtt` | uz | 712 B | `caed55b7f44602e29fbf2bb8caa56d79f05a1b28246b580f9114e276c9376de8` |
| `03_preanalitika_ru.srt` | ru | 1021 B | `b5c7c61054cb4264ac2e80fff1c9aa1ed126e4e9306792e6f6b5cec5e6ba15f7` |
| `03_preanalitika_ru.vtt` | ru | 1029 B | `c1157c80c7eaa1ec92042539a5be44b0177952352483127d554171b133f3a034` |
| `03_preanalitika_en.srt` | en | 693 B | `f1ba84fb9db58312f8f7851e8d6196f392b273b79bfda6564e0f0b32cf640418` |
| `03_preanalitika_en.vtt` | en | 701 B | `3517801ab695a9cdeef13c25da525fafecf2587f4dba5fbdb6a8b2d5df8f9995` |
| `04_kalkulyatorlar_uz.srt` | uz | 803 B | `b1f1046a98865e575b8401dfd0db3001b3a7473750b2ededf6269531c5b3ceca` |
| `04_kalkulyatorlar_uz.vtt` | uz | 811 B | `2ae1d38e21f8bf3a5f57b8953ac348eb9d3f321b045582d05e0c673521315c89` |
| `04_kalkulyatorlar_ru.srt` | ru | 1100 B | `4b95f660cd3b1c5361082320202de3139b67e2391bd23ae34274fa85c09ead4c` |
| `04_kalkulyatorlar_ru.vtt` | ru | 1108 B | `894875ac999a158f35f723f49a7d75c335983d55078a91b1dbcb2260e955f075` |
| `04_kalkulyatorlar_en.srt` | en | 768 B | `6d26e6eb7e359c65457b14ebae875b70c4f038c8af9fed2ea0714742cebcff73` |
| `04_kalkulyatorlar_en.vtt` | en | 776 B | `049ebd2c75817506211308a9bda34fe3c04208134c554d1fa91e13c3f60e730a` |
| `05_apparatlar_uz.srt` | uz | 1145 B | `8669a71f63f5dea425439a750d4e5f53927b5f48ec767fc1531327e75676edfd` |
| `05_apparatlar_uz.vtt` | uz | 1153 B | `1df552cf78fd15b1d39f43a6c2408eaca990f72ed71b341dd9e757a009b8cf2f` |
| `05_apparatlar_ru.srt` | ru | 1650 B | `8be5cf5ed69cc9b1e3dfd0f04aa0ef31f6722a39edf49b041e84996db61411b7` |
| `05_apparatlar_ru.vtt` | ru | 1658 B | `a120b37f1ab07cddf01f6e40e474ae2fc95cc515484fbb7bd0361a865c80b8b6` |
| `05_apparatlar_en.srt` | en | 1103 B | `fce560a1d2b31684e40f764bc0b9d6b83ab544a05d6f8a91963be10e49a825d7` |
| `05_apparatlar_en.vtt` | en | 1111 B | `23f3e1573876c4a7ade822962ff8f258e4bc3715b0f8f1dcb9f4ab282ec535db` |
| `06_mikroskopiya_uz.srt` | uz | 1048 B | `f9c330254a38c52b8a36933e2ce425299e2f9d753f9d6836d1ba3f76502f49f5` |
| `06_mikroskopiya_uz.vtt` | uz | 1056 B | `d39f5dab0725d0c2d78315316774e84959de3ee6a02a6a07dd48769ac85a5cc8` |
| `06_mikroskopiya_ru.srt` | ru | 1522 B | `b39eac3cae8376152e4940b76c555b875362642db0eec7244a229dd1d6f83060` |
| `06_mikroskopiya_ru.vtt` | ru | 1530 B | `1d6a89ee584e2fa46f7080f37525b045c8d6e8c8b478a7d2dfbe7df70afe3262` |
| `06_mikroskopiya_en.srt` | en | 1037 B | `4d7fe6b1db49cb8b761ece9effaefb1a76d04046dfb90e22db0ad15a9ff94464` |
| `06_mikroskopiya_en.vtt` | en | 1045 B | `5d10f9a3a8075604161b986fa1722a1ae24d6e2bbe3fb2e473c1680507bff273` |
| `07_najas_parazitologiya_uz.srt` | uz | 983 B | `3873af1da457e23b2a154217821bf7acc8dfc630e0a7b2c771328efa208af306` |
| `07_najas_parazitologiya_uz.vtt` | uz | 991 B | `2843673a6f9f58c0e87bc4bb1e12d2a70daa1f2123d076a4bceef42e7f08c17f` |
| `07_najas_parazitologiya_ru.srt` | ru | 1443 B | `5c4a55ad19f4cf126247962d3925549e11878aa6379f4a8f802aabcbccd291b8` |
| `07_najas_parazitologiya_ru.vtt` | ru | 1451 B | `e61dfd257da01cd286a83b20bc8c967b499f438e06008094622d6f1063fa86ad` |
| `07_najas_parazitologiya_en.srt` | en | 992 B | `692bb6ea1c592751cade89ac6d73f65f33680b6a873ae62c0f0a24cb81bee398` |
| `07_najas_parazitologiya_en.vtt` | en | 1000 B | `f0c0bafb46479ea46a3bdd42fa734fd52ed7a79c0447731e4088ffda8485f836` |
| `08_bilim_baholash_uz.srt` | uz | 1386 B | `ee755d758304f6827032fa64c02ceccdc7a149b1d8b6304f0a3d4b0f935ac195` |
| `08_bilim_baholash_uz.vtt` | uz | 1394 B | `fe8797e075b5ec9f6231f1ab924c3ae2e9687c3befd9f1bbc27b68e12954e37b` |
| `08_bilim_baholash_ru.srt` | ru | 2132 B | `09f69663751a5820c32e227500220faf8ab9f785796415907353f55e54f236d9` |
| `08_bilim_baholash_ru.vtt` | ru | 2140 B | `86fa652fcbd0552ae35b6032b900bb20b0e93c55faa780c2587cc4d59c70ec1d` |
| `08_bilim_baholash_en.srt` | en | 1480 B | `f818bd048e451423dc70982a57e8ad20b04ddc80f2952979720a7f98b3caa402` |
| `08_bilim_baholash_en.vtt` | en | 1488 B | `7d896297dc401a3f09cec1195fc36b8fddce0b95fae4c7b8ce4040a23b6dd5a8` |
| `09_testlar_natijalar_uz.srt` | uz | 1036 B | `f47898828955428e0f82b3dda8c46a9bfab6afd725eb5da65ca457b322aba605` |
| `09_testlar_natijalar_uz.vtt` | uz | 1044 B | `ba346ddfb6330dd51b671442213a9b503b01de4db686c2871a23139bb574f3b9` |
| `09_testlar_natijalar_ru.srt` | ru | 1471 B | `b90221c0fdcc7c4da7458009196116cf1920555724fe6b93a9f21a2ee953f99f` |
| `09_testlar_natijalar_ru.vtt` | ru | 1479 B | `231520f2bcf4fb1fd3106d1bfc8f1cb320bf4918294969044fc5d76f980ad667` |
| `09_testlar_natijalar_en.srt` | en | 1025 B | `71714da2c9c95281cfdab8cdfee0fcdacc8983613b11b14b81f05b7cb3183da1` |
| `09_testlar_natijalar_en.vtt` | en | 1033 B | `060fe98479fa5dfa60e33a2c7a0124c7ca00535b07960512f275b8157763f64d` |
| `10_boshqa_funksiyalar_uz.srt` | uz | 1422 B | `d2fb6b2fde6341900332790095a6673ced23674899e022d7b4be8c5158c85eac` |
| `10_boshqa_funksiyalar_uz.vtt` | uz | 1430 B | `fa3005d99790237ccf0714f7882a7939f22ebe0908220f7f87dca40f6876a254` |
| `10_boshqa_funksiyalar_ru.srt` | ru | 1996 B | `7a0aab5bb9d3d9055d7a26aa65a4b3d721aad6dc9e434369892c916d1957cd11` |
| `10_boshqa_funksiyalar_ru.vtt` | ru | 2004 B | `c255ff44b26374dc2535361ab679f3697c684f99ef053da20e79e93a93ced658` |
| `10_boshqa_funksiyalar_en.srt` | en | 1355 B | `8a23b4eab3d8de061e8446169e4efe6c20fb82b16be9e48e5003f0a8e2e3eaa5` |
| `10_boshqa_funksiyalar_en.vtt` | en | 1363 B | `ac7190955772d9e2493fb76fe37afc1d0f31108b3fede01c24b01a76aecb3a10` |
