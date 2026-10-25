# Video qo‘llanmalar — chiqarilgan fayllar

**Yorliq: ovozsiz, subtitrli ekran yozuvi — diktorsiz.** Har video — ilovaning haqiqiy ekranlari
(widget test render, serversiz, haqiqiy kontent) dan yig‘ilgan; ovoz yo‘q, diktor yo‘q (TTS vositasi
yo‘q). Subtitrlar kadrga yozilgan (burned-in) va alohida SRT/VTT fayl sifatida ham bor.

Fayllar repoga qo‘shilmaydi: `build/video_out/` (gitignore). Qayta yig‘ish — `docs/video/PLAN.md`.
Bu jadval `python3 tool/video/report.py` bilan ffprobe va sha256 orqali o‘lchab yozilgan.

| Fayl | Til | Davomiylik | O‘lcham | Kodek, fps | Audio | Hajm | sha256 |
|---|---|---|---|---|---|---|---|
| `01_kalibrlash_uz.mp4` | uz | 45.5 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.31 MB | `6146fd8794d4d3afef269a91901fa174cbe9f62b562b24336044354ebcd2fda7` |
| `01_kalibrlash_ru.mp4` | ru | 45.5 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.34 MB | `95c731cd1bff319a1158a6d72a025a1a43e70b7164a55818ea518ab97568a372` |
| `01_kalibrlash_en.mp4` | en | 45.5 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.23 MB | `89afa9c4e4950ce9b761b43d26c4028e477bce96f1f52b403e95f741757de7a8` |
| `02_sifat_nazorati_uz.mp4` | uz | 46.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.28 MB | `0584f01843fe7ee8e88cbdbfddaa480c14bc67e0bdc81cc628c6da292f7d4edd` |
| `02_sifat_nazorati_ru.mp4` | ru | 46.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.32 MB | `c70389d7b13ffdeb17b306cd24f9d441c9ba0dbb0f6077e7a4041166407942e6` |
| `02_sifat_nazorati_en.mp4` | en | 46.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.21 MB | `060353c9d0240a67cbbb2077dfdabca94b22c8ed26a6c6ff566115dad174712e` |
| `03_preanalitika_uz.mp4` | uz | 31.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 0.97 MB | `cbefd28a146393386a7e9a90a2b3f8c3468c7f7cd254cd58d0bfceba82e2ad88` |
| `03_preanalitika_ru.mp4` | ru | 31.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.03 MB | `121b6ca0fc9caf2dc2466d71ce684f632bedea2ae08c61b1233939ea7e66bc1a` |
| `03_preanalitika_en.mp4` | en | 31.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 0.95 MB | `9230042fed41dab22d4f5f4063965c92d050b734191d2beb52c2556139671b2b` |
| `04_kalkulyatorlar_uz.mp4` | uz | 33.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 0.98 MB | `8df423b3bbc237043a7e1d604545955b86e1e80aaec9b2b0e0b7d81bfbdc4ede` |
| `04_kalkulyatorlar_ru.mp4` | ru | 33.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.01 MB | `05828149272dfc35ec24142ad30ed52437253770defb76bf7ca06a92f6da327d` |
| `04_kalkulyatorlar_en.mp4` | en | 33.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 0.94 MB | `53001b6497be923cad7d87e019f47554b934b5ec7ef45c025d44a6e2fb1a414a` |
| `05_apparatlar_uz.mp4` | uz | 47.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.48 MB | `7a44a8a6562575f9fb4f738b8f79db3d6b47ecc4eaa25627c6c35d52b994861f` |
| `05_apparatlar_ru.mp4` | ru | 47.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.53 MB | `9f84449ee03ac50885b043ce31ca1197527bd8044936ec58e73a425d9be89d7e` |
| `05_apparatlar_en.mp4` | en | 47.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.42 MB | `a4296f233564b55aa527c966ca220a4f86d0436d099e1866f2eb2db4192fdc3f` |
| `06_mikroskopiya_uz.mp4` | uz | 50.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.49 MB | `dcb72bdf89c8387ebfc1791def4496cd459897833c0a34d204a09a1c58ff5286` |
| `06_mikroskopiya_ru.mp4` | ru | 50.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.48 MB | `76c26c413138b9a2111087e2bdfcf8da9d7d6a439f9bdc0d619e1614bff3e316` |
| `06_mikroskopiya_en.mp4` | en | 50.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.44 MB | `b532cdc3622625fdd8701df818f43d70968ad950dd810393a5551201b928c431` |
| `07_najas_parazitologiya_uz.mp4` | uz | 41.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.39 MB | `418ce51262a4640a97b217d0c336503bd84eeaa2adaeca40f13db9a581edb2f3` |
| `07_najas_parazitologiya_ru.mp4` | ru | 41.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.43 MB | `e850ada13914539f14baf8a08e98ea35aa0d70ffc0a37286231de6bb6f2e5dce` |
| `07_najas_parazitologiya_en.mp4` | en | 41.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.42 MB | `4a860bf77f2e44c96d319d780b4f5250c4a0f6806ebba041bbdcd8f7e969dba7` |
| `08_bilim_baholash_uz.mp4` | uz | 59.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.54 MB | `bc36f70168e060110e5433a26dda04ec3f264c2d1308baec58a56216ff4c6c0b` |
| `08_bilim_baholash_ru.mp4` | ru | 64.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.86 MB | `994744768278698482c2f241c0ce4d14f6a40eb301bc189777a2794e615ae984` |
| `08_bilim_baholash_en.mp4` | en | 64.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.80 MB | `357c20429349d65d37ba44b97b6093857ceecec7e03684302658d82acf11bce3` |
| `09_testlar_natijalar_uz.mp4` | uz | 46.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.36 MB | `89fc47474fe9fd388190c550e63ae072ecb8185ca845fb8cb8146bb037f64330` |
| `09_testlar_natijalar_ru.mp4` | ru | 46.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.39 MB | `98c7fd6e1a46f5bc2f0fbfa7b889fbd284d4aaad1926239258ff6346896676cc` |
| `09_testlar_natijalar_en.mp4` | en | 46.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.30 MB | `85413b5847471edde9c632bbd7d334453eeb499d1290c30063b9c5ca60a4acfc` |
| `10_boshqa_funksiyalar_uz.mp4` | uz | 63.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.97 MB | `38e002a38b1020b6d02a4a934599ebacece07221ccc4ceb87951cc575cb3f395` |
| `10_boshqa_funksiyalar_ru.mp4` | ru | 63.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.95 MB | `e4b607ebe7b0d94e699b72319dc818850d5277467efbdec2ceb0932766996533` |
| `10_boshqa_funksiyalar_en.mp4` | en | 63.0 s | 720×1280 | h264, 24 | yo‘q (0 oqim) | 1.93 MB | `8a3b24f22254279eda599010856f526e179fd4ce387ff20a5b5feb729b83433a` |

Jami: 30 ta MP4, 41.8 MB.

## Subtitr va mualliflik fayllari (SRT / VTT / credits.txt)

credits.txt — videoda ko‘rinadigan uchinchi tomon rasmlarining muallifi, litsenziyasi va manba havolasi; video e’lon qilinsa, tavsifga shu matn qo‘shiladi.

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
| `06_mikroskopiya_uz.srt` | uz | 1155 B | `a461cbee4609495075b5311a086412b58adf9e455775a6eb86d3f55da1ba9cd9` |
| `06_mikroskopiya_uz.vtt` | uz | 1163 B | `4f4bb301d532204b51bee843145e12798eafc054a08208901d0c1ee72e2da80f` |
| `06_mikroskopiya_uz_credits.txt` | uz | 4363 B | `30191891ca73c8f1397bc24feeb08fead03d9276586ce9b3a13ce574605fa921` |
| `06_mikroskopiya_ru.srt` | ru | 1639 B | `2c51daf1e9d8ea40259e3d727166f01ddc1d0581df681369242ad8ef29121336` |
| `06_mikroskopiya_ru.vtt` | ru | 1647 B | `cad57bdcff73be90619483ebf118194ace5e4d99a4d5ee058edb44aa61ba8cdd` |
| `06_mikroskopiya_ru_credits.txt` | ru | 4798 B | `8df3575f57b2bdb82bdda13d79611774f1ff4a298207241d2dca53d21c512bd4` |
| `06_mikroskopiya_en.srt` | en | 1133 B | `e5434a50ea685a8003d37e0ffb447036c0f99bb0f2fc38600d42e49b75dc4f17` |
| `06_mikroskopiya_en.vtt` | en | 1141 B | `bca751e428edb2a2f0b32eac31eb270ae72d8d767160e5787c248d4552218e5b` |
| `06_mikroskopiya_en_credits.txt` | en | 4662 B | `72be7c5cb428998e12ba8eb2ac41ce70169429333153dd2ca9f3396f2504bbbd` |
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
| `10_boshqa_funksiyalar_uz.srt` | uz | 1535 B | `03e14ea69e0f5f0ea6951010b40479729600865bf981f2fa45fd6a26b157786d` |
| `10_boshqa_funksiyalar_uz.vtt` | uz | 1543 B | `469b0954f03603ecab34dde862f524a47f9c2b82215b6fb059175a28efc40f37` |
| `10_boshqa_funksiyalar_uz_credits.txt` | uz | 2918 B | `0cdf0345898abd6f634e873ebe2929e2c29c1c76c71240f6166f6d57c5013e80` |
| `10_boshqa_funksiyalar_ru.srt` | ru | 2119 B | `5b25a935cfda9316919ac83c313840885e53d14272ab4c47be168fbc4a75973a` |
| `10_boshqa_funksiyalar_ru.vtt` | ru | 2127 B | `fda20cbeb41a2b5b1030e3ef040186bf35c552c6155d2b1c1b1951718e08b83e` |
| `10_boshqa_funksiyalar_ru_credits.txt` | ru | 2626 B | `0c6ca8dac35fa6641bf3e6d0db4c023f28fdf878ddcc45725f5839f90de61b2f` |
| `10_boshqa_funksiyalar_en.srt` | en | 1457 B | `8820ec0555075826555987f782173d1562174db51714fffaea913b63df11579e` |
| `10_boshqa_funksiyalar_en.vtt` | en | 1465 B | `024d503cdeca1009849e81f9fcec37ddb202a8927b56a2d516c56c1f2deed658` |
| `10_boshqa_funksiyalar_en_credits.txt` | en | 2896 B | `028331dbd997d1fe6d4e552ddd1f3816578a17903d1bdac946ab48b81dc33649` |
