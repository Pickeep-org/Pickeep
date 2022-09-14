import 'dart:io';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pickeep/category_screen.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:pickeep/filters.dart';
import 'package:pickeep/firestore/firestore_items.dart';
import 'item.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({Key? key}) : super(key: key);

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  // TODO: change to nullable and set default text on build instead
  List<String> locations = [
    "ABBIRIM ","ABU ABDUN ","ABU AMMAR ","ABU AMRE ","ABU GHOSH ","ABU JUWEI'ID ","ABU QUREINAT ","ABU RUBEI'A ","ABU RUQAYYEQ ","ABU SINAN ","ABU SUREIHAN ","ABU TULUL ","ADAMIT ","ADANIM ","ADDERET ","ADDIRIM ","ADI ","ADORA ","AFEINISH ","AFEQ ","AFIQ ","AFIQIM ","AFULA ","AGUR ","AHAWA ","AHI'EZER ","AHIHUD ","AHISAMAKH ","AHITUV ","AHUZZAM ","AHUZZAT BARAQ ","AKKO ","AL SAYYID ","AL-ARYAN ","AL-AZY ","ALE ZAHAV ","ALFE MENASHE ","ALLON HAGALIL ","ALLON SHEVUT ","ALLONE ABBA ","ALLONE HABASHAN ","ALLONE YIZHAQ ","ALLONIM ","ALMA ","ALMAGOR ","ALMOG ","ALMON ","ALUMIM ","ALUMMA ","ALUMMOT ","AMAZYA ","AMIR ","AMIRIM ","AMMI'AD ","AMMIHAY ","AMMINADAV ","AMMI'OZ ","AMMIQAM ","AMNUN ","AMQA ","AMUQQA ","ANI'AM ","ARAD ","ARAMSHA ","AR'ARA ","AR'ARA-BANEGEV ","ARBEL ","ARGAMAN ","ARI'EL ","ARRAB AL NAIM ","ARRABE ","ARSUF ","ARUGOT ","ASAD ","A'SAM ","ASEFAR ","ASERET ","ASHALIM ","ASHDOD ","ASHDOT YA'AQOV(IHUD) ","ASHDOT YA'AQOV(ME'UH ","ASHERAT ","ASHQELON ","ATAWNE ","ATERET ","ATLIT ","ATRASH ","ATSMON-SEGEV ","AVDON ","AVENAT ","AVI'EL ","AVI'EZER ","AVIGEDOR ","AVIHAYIL ","AVITAL ","AVIVIM ","AVNE ETAN ","AVNE HEFEZ ","AVSHALOM ","AVTALYON ","AYANOT ","AYYELET HASHAHAR ","AZARYA ","AZOR ","AZRI'EL ","AZRIQAM ","BAHAN ","BALFURIYYA ","BAQA AL-GHARBIYYE ","BAR GIYYORA ","BAR YOHAY ","BAR'AM ","BARAQ ","BAREQET ","BARQAN ","BARQAY ","BASMA ","BASMAT TAB'UN ","BAT AYIN ","BAT HADAR ","BAT HEFER ","BAT HEN ","BAT SHELOMO ","BAT YAM ","BAZRA ","BEER GANNIM ","BE'ER MILKA ","BE'ER ORA ","BE'ER SHEVA ","BE'ER TUVEYA ","BE'ER YA'AQOV ","BE'ERI ","BE'EROT YIZHAQ ","BE'EROTAYIM ","BEIT JANN ","BEN AMMI ","BEN SHEMEN (MOSHAV) ","BEN SHEMEN(K.NO'AR) ","BEN ZAKKAY ","BENAYA ","BENE ATAROT ","BENE AYISH ","BENE BERAQ ","BENE DAROM ","BENE DEROR ","BENE NEZARIM ","BENE RE'EM ","BENE YEHUDA ","BENE ZIYYON ","BEQA'OT ","BEQOA ","BERAKHA ","BEREKHYA ","BEROR HAYIL ","BEROSH ","BET ALFA ","BET ARIF ","BET ARYE ","BET BERL ","BET DAGAN ","BET EL ","BET EL'AZARI ","BET EZRA ","BET GAMLI'EL ","BET GUVRIN ","BET HAARAVA ","BET HAEMEQ ","BET HAGADDI ","BET HALEVI ","BET HANAN ","BET HANANYA ","BET HASHITTA ","BET HASHMONAY ","BET HERUT ","BET HILLEL ","BET HILQIYYA ","BET HORON ","BET LEHEM HAGELILIT ","BET ME'IR ","BET NEHEMYA ","BET NEQOFA ","BET NIR ","BET OREN ","BET OVED ","BET QAMA ","BET QESHET ","BET RABBAN ","BET RIMMON ","BET SHE'AN ","BET SHE'ARIM ","BET SHEMESH ","BET SHIQMA ","BET UZZI'EL ","BET YANNAY ","BET YEHOSHUA ","BET YIZHAQ-SH. HEFER ","BET YOSEF ","BET ZAYIT ","BET ZEID ","BET ZERA ","BET ZEVI ","BETAR ILLIT ","BEZET ","BI NE ","BINYAMINA ","BIR EL-MAKSUR ","BIR HADAGE ","BIRIYYA ","BITAN AHARON ","BITHA ","BIZZARON ","BNE DKALIM ","BRUKHIN ","BU'EINE-NUJEIDAT ","BUQ'ATA ","BURGETA ","BUSTAN HAGALIL ","DABBURYE ","DAFNA ","DAHI ","DALIYAT AL-KARMEL ","DALIYYA ","DALTON ","DAN ","DAVERAT ","DEGANYA ALEF ","DEGANYA BET ","DEIR AL-ASAD ","DEIR HANNA ","DEIR RAFAT ","DEMEIDE ","DEQEL ","DERIG'AT ","DEVIRA ","DEVORA ","DIMONA ","DISHON ","DOLEV ","DOR ","DOROT ","DOVEV ","EFRAT ","EILABUN ","EIN AL-ASAD ","EIN HOD ","EIN MAHEL ","EIN NAQQUBA ","EIN QINIYYE ","EIN RAFA ","EL'AD ","ELAT ","EL'AZAR ","ELI ","ELI AL ","ELIAV ","ELIFAZ ","ELIFELET ","ELISHAMA ","ELON ","ELON MORE ","ELOT ","ELQANA ","ELQOSH ","EL-ROM ","ELYAKHIN ","ELYAQIM ","ELYASHIV ","EMUNIM ","EN AYYALA ","EN DOR ","EN GEDI ","EN GEV ","EN HABESOR ","EN HAEMEQ ","EN HAHORESH ","EN HAMIFRAZ ","EN HANAZIV ","EN HAROD (IHUD) ","EN HAROD(ME'UHAD) ","EN HASHELOSHA ","EN HASHOFET ","EN HAZEVA ","EN HOD ","EN IRON ","EN KAREM-B.S.HAQLA'I ","EN KARMEL ","EN SARID ","EN SHEMER ","EN TAMAR ","EN WERED ","EN YA'AQOV ","EN YAHAV ","EN ZIWAN ","EN ZURIM ","ENAT ","ENAV ","EREZ ","ESHBOL ","ESHEL HANASI ","ESHHAR ","ESHKOLOT ","ESHTA'OL ","ETAN ","ETANIM ","ETGAR ","EVEN MENAHEM ","EVEN SAPPIR ","EVEN SHEMU'EL ","EVEN YEHUDA ","EVEN YIZHAQ(GAL'ED) ","EVRON ","EYAL ","EZ EFRAYIM ","EZER ","EZUZ ","FASSUTA ","FUREIDIS ","GA'ASH ","GADISH ","GADOT ","GAL'ON ","GAN HADAROM ","GAN HASHOMERON ","GAN HAYYIM ","GAN NER ","GAN SHELOMO ","GAN SHEMU'EL ","GAN SOREQ ","GAN YAVNE ","GAN YOSHIYYA ","GANNE AM ","GANNE HADAR ","GANNE MODIIN ","GANNE TAL ","GANNE TIQWA ","GANNE YOHANAN ","GANNOT ","GANNOT HADAR ","GAT RIMMON ","GAT(QIBBUZ) ","GA'TON ","GAZIT ","GE'A ","GE'ALYA ","GEDERA ","GEFEN ","GELIL YAM ","GEROFIT ","GESHER ","GESHER HAZIW ","GESHUR ","GE'ULE TEMAN ","GE'ULIM ","GEVA ","GEVA BINYAMIN ","GEVA KARMEL ","GEVA'OT BAR ","GEVAR'AM ","GEVAT ","GEVIM ","GEVULOT ","GEZER ","GHAJAR ","GIBBETON ","GID'ONA ","GILAT ","GILGAL ","GILON ","GIMZO ","GINNATON ","GINNEGAR ","GINNOSAR ","GITTA ","GITTIT ","GIV'AT AVNI ","GIV'AT BRENNER ","GIV'AT ELA ","GIV'AT HASHELOSHA ","GIV'AT HAYYIM (IHUD) ","GIV'AT HAYYIM(ME'UHA ","GIV'AT HEN ","GIV'AT KOAH ","GIV'AT NILI ","GIV'AT OZ ","GIV'AT SHAPPIRA ","GIV'AT SHEMESH ","GIV'AT SHEMU'EL ","GIV'AT YE'ARIM ","GIV'AT YESHA'YAHU ","GIV'AT YO'AV ","GIV'AT ZE'EV ","GIV'ATAYIM ","GIV'ATI ","GIV'OLIM ","GIV'ON HAHADASHA ","GIV'OT EDEN ","GIZO ","GONEN ","GOREN ","GORNOT HAGALIL ","HABONIM ","HADAR AM ","HADERA ","HADID ","HAD-NES ","HAFEZ HAYYIM ","HAGGAI ","HAGOR ","HAGOSHERIM ","HAHOTERIM ","HAIFA ","HALUZ ","HAMADYA ","HAMAM ","HAMA'PIL ","HAMRA ","HANITA ","HANNATON ","HANNI'EL ","HAOGEN ","HAON ","HAR ADAR ","HAR AMASA ","HAR GILLO ","HARARIT ","HARASHIM ","HARDUF ","HAR'EL ","HARISH ","HARUZIM ","HASHMONA'IM ","HASOLELIM ","HASPIN ","HAVAZZELET HASHARON ","HAWASHLA ","HAYOGEV ","HAZAV ","HAZERIM ","HAZEVA ","HAZON ","HAZOR HAGELILIT ","HAZOR-ASHDOD ","HAZOREA ","HAZORE'IM ","HEFZI-BAH ","HELEZ ","HEMED ","HEREV LE'ET ","HERMESH ","HERUT ","HERZELIYYA ","HEVER ","HIBBAT ZIYYON ","HILLA ","HINNANIT ","HOD HASHARON ","HODAYOT ","HODIYYA ","HOFIT ","HOGLA ","HOLIT ","HOLON ","HORESHIM ","HOSEN ","HOSHA'AYA ","HUJEIRAT (DAHRA) ","HULATA ","HULDA ","HUQOQ ","HURA ","HURFEISH ","HUSSNIYYA ","HUZAYYEL ","IBBIM ","I'BILLIN ","IBTIN ","IDDAN ","IKSAL ","ILANIYYA ","ILUT ","IMMANU'EL ","IR OVOT ","IRUS ","ISIFYA ","ITAMAR ","JAAT ","JALJULYE ","JERUSALEM ","JISH(GUSH HALAV) ","JISR AZ-ZARQA ","JUDEIDE-MAKER ","JULIS ","JUNNABIB ","KA'ABIYYE-TABBASH-HA ","KABRI ","KABUL ","KADDITA ","KADOORIE ","KAFAR BARA ","KAFAR KAMA ","KAFAR KANNA ","KAFAR MANDA ","KAFAR MISR ","KAFAR QARA ","KAFAR QASEM ","KAFAR YASIF ","KAHAL ","KALLANIT ","KAMMON ","KANAF ","KANNOT ","KAOKAB ABU AL-HIJA ","KARE DESHE ","KARKOM ","KARME QATIF ","KARME YOSEF ","KARME ZUR ","KARMEL ","KARMI'EL ","KARMIYYA ","KEFAR ADUMMIM ","KEFAR AHIM ","KEFAR AVIV ","KEFAR AVODA ","KEFAR AZZA ","KEFAR BARUKH ","KEFAR BIALIK ","KEFAR BILU ","KEFAR BIN NUN ","KEFAR BLUM ","KEFAR DANIYYEL ","KEFAR EZYON ","KEFAR GALLIM ","KEFAR GID'ON ","KEFAR GIL'ADI ","KEFAR GLIKSON ","KEFAR HABAD ","KEFAR HAHORESH ","KEFAR HAMAKKABI ","KEFAR HANAGID ","KEFAR HANANYA ","KEFAR HANASI ","KEFAR HANO'AR HADATI ","KEFAR HAORANIM ","KEFAR HARIF ","KEFAR HARO'E ","KEFAR HARUV ","KEFAR HASIDIM ALEF ","KEFAR HASIDIM BET ","KEFAR HAYYIM ","KEFAR HESS ","KEFAR HITTIM ","KEFAR HOSHEN ","KEFAR KISH ","KEFAR MALAL ","KEFAR MASARYK ","KEFAR MAYMON ","KEFAR MENAHEM ","KEFAR MONASH ","KEFAR MORDEKHAY ","KEFAR NETTER ","KEFAR PINES ","KEFAR ROSH HANIQRA ","KEFAR ROZENWALD(ZAR. ","KEFAR RUPPIN ","KEFAR RUT ","KEFAR SAVA ","KEFAR SHAMMAY ","KEFAR SHEMARYAHU ","KEFAR SHEMU'EL ","KEFAR SILVER ","KEFAR SIRKIN ","KEFAR SZOLD ","KEFAR TAPPUAH ","KEFAR TAVOR ","KEFAR TRUMAN ","KEFAR URIYYA ","KEFAR VITKIN ","KEFAR WARBURG ","KEFAR WERADIM ","KEFAR YA'BEZ ","KEFAR YEHEZQEL ","KEFAR YEHOSHUA ","KEFAR YONA ","KEFAR ZETIM ","KEFAR ZOHARIM ","KELIL ","KEMEHIN ","KERAMIM ","KEREM BEN SHEMEN ","KEREM BEN ZIMRA ","KEREM MAHARAL ","KEREM SHALOM ","KEREM YAVNE(YESHIVA) ","KESALON ","KHAWALED ","KINNERET(MOSHAVA) ","KINNERET(QEVUZA) ","KISHOR ","KISRA-SUMEI ","KISSUFIM ","KOCHLEA ","KOKHAV HASHAHAR ","KOKHAV MIKHA'EL ","KOKHAV YA'AQOV ","KOKHAV YA'IR ","KORAZIM ","KUSEIFE ","LAHAV ","LAHAVOT HABASHAN ","LAHAVOT HAVIVA ","LAKHISH ","LAPPID ","LAPPIDOT ","LAQYE ","LAVI ","LAVON ","LEHAVIM ","LIMAN ","LI-ON ","LIVNIM ","LOD ","LOHAME HAGETA'OT ","LOTAN ","LOTEM ","LUZIT ","MA'AGAN ","MA'AGAN MIKHA'EL ","MA'ALE ADUMMIM ","MA'ALE AMOS ","MA'ALE EFRAYIM ","MA'ALE GAMLA ","MA'ALE GILBOA ","MA'ALE HAHAMISHA ","MA'ALE IRON ","MA'ALE LEVONA ","MA'ALE MIKHMAS ","MA'ALOT-TARSHIHA ","MA'ANIT ","MA'AS ","MA'BAROT ","MABBU'IM ","MA'GALIM ","MAGEN ","MAGEN SHA'UL ","MAGGAL ","MAGSHIMIM ","MAHANAYIM ","MAHANE BILDAD ","MAHANE HILLA ","MAHANE MIRYAM ","MAHANE TALI ","MAHANE TEL NOF ","MAHANE YAFA ","MAHANE YATTIR ","MAHANE YEHUDIT ","MAHANE YOKHVED ","MAHSEYA ","MAJD AL-KURUM ","MAJDAL SHAMS ","MAKCHUL ","MALKISHUA ","MALKIYYA ","MANOF ","MANOT ","MANSHIYYET ZABDA ","MA'ON ","MA'OR ","MA'OZ HAYYIM ","MARGALIYYOT ","MAS'ADE ","MASH'ABBE SADE ","MASH'EN ","MASKIYYOT ","MASLUL ","MASSAD ","MASSADA ","MASSU'A ","MASSUOT YIZHAQ ","MAS'UDIN AL-'AZAZME ","MATTA ","MATTAN ","MATTAT ","MATTITYAHU ","MAVQI'IM ","MA'YAN BARUKH ","MA'YAN ZEVI ","MAZKERET BATYA ","MAZLIAH ","MAZOR ","MAZRA'A ","MAZZUVA ","ME AMMI ","MEFALLESIM ","MEGADIM ","MEGIDDO ","MEHOLA ","ME'IR SHEFEYA ","MEISER ","MEKHORA ","MELE'A ","MELILOT ","MENAHEMYA ","MENNARA ","MENUHA ","ME'ONA ","MERAV ","MERHAV AM ","MERHAVYA(MOSHAV) ","MERHAVYA(QIBBUZ) ","MERKAZ SHAPPIRA ","MEROM GOLAN ","MERON ","MESHAR ","MESHHED ","MESILLAT ZIYYON ","MESILLOT ","METAR ","METAV ","METULA ","MEVASSERET ZIYYON ","MEVO BETAR ","MEVO DOTAN ","MEVO HAMMA ","MEVO HORON ","MEVO MODI'IM ","MEVO'OT YAM ","MEVO'OT YERIHO ","MEZADOT YEHUDA ","MEZAR ","MEZER ","MIDRAKH OZ ","MIDRESHET BEN GURION ","MIDRESHET RUPPIN ","MI'ELYA ","MIGDAL ","MIGDAL HAEMEQ ","MIGDAL OZ ","MIGDALIM ","MIKHMANNIM ","MIKHMORET ","MIQWE YISRA'EL ","MISGAV AM ","MISGAV DOV ","MISHMAR AYYALON ","MISHMAR DAWID ","MISHMAR HAEMEQ ","MISHMAR HANEGEV ","MISHMAR HASHARON ","MISHMAR HASHIV'A ","MISHMAR HAYARDEN ","MISHMAROT ","MISHMERET ","MITSPE ILAN ","MIVTAHIM ","MIZPA ","MIZPE AVIV ","MIZPE NETOFA ","MIZPE RAMON ","MIZPE SHALEM ","MIZPE YERIHO ","MIZRA ","MODI'IN ILLIT ","MODI'IN-MAKKABBIM-RE ","MOLEDET ","MORAN ","MORESHET ","MOZA ILLIT ","MUGHAR ","MUQEIBLE ","NA'ALE ","NAAMA ","NA'AN ","NA'ARAN ","NAHAL ESHBAL ","NAHAL HEMDAT ","NAHAL OZ ","NAHAL SHITTIM ","NAHALA ","NAHALAL ","NAHALI'EL ","NAHAM ","NAHARIYYA ","NAHEF ","NAHSHOLIM ","NAHSHON ","NAHSHONIM ","NASASRA ","NATAF ","NATUR ","NA'URA ","NAVE ","NAZARETH ","NEGBA ","NEGOHOT ","NEHALIM ","NEHORA ","NEHUSHA ","NEIN ","NE'OT GOLAN ","NE'OT HAKIKKAR ","NE'OT MORDEKHAY ","NES AMMIM ","NES HARIM ","NES ZIYYONA ","NESHER ","NETA ","NETA'IM ","NETANYA ","NETIV HAASARA ","NETIV HAGEDUD ","NETIV HALAMED-HE ","NETIV HASHAYYARA ","NETIVOT ","NETU'A ","NE'URIM ","NEVATIM ","NEVE TSUF ","NEWE ATIV ","NEWE AVOT ","NEWE DANIYYEL ","NEWE ETAN ","NEWE HARIF ","NEWE ILAN ","NEWE MIKHA'EL ","NEWE MIVTAH ","NEWE SHALOM ","NEWE UR ","NEWE YAM ","NEWE YAMIN ","NEWE YARAQ ","NEWE ZIV ","NEWE ZOHAR ","NEZER HAZZANI ","NEZER SERENI ","NILI ","NIMROD ","NIR AM ","NIR AQIVA ","NIR BANIM ","NIR DAWID (TEL AMAL) ","NIR ELIYYAHU ","NIR EZYON ","NIR GALLIM ","NIR HEN ","NIR MOSHE ","NIR OZ ","NIR YAFE ","NIR YISRA'EL ","NIR YIZHAQ ","NIR ZEVI ","NIRIM ","NIRIT ","NIZZAN ","NIZZAN B ","NIZZANA (QEHILAT HIN ","NIZZANE OZ ","NIZZANE SINAY ","NIZZANIM ","NO'AM ","NOF AYYALON ","NOF HAGALIL ","NOFEKH ","NOFIM ","NOFIT ","NOGAH ","NOQEDIM ","NORDIYYA ","NOV ","NURIT ","ODEM ","OFAQIM ","OFER ","OFRA ","OHAD ","OLESH ","OMEN ","OMER ","OMEZ ","OR AQIVA ","OR HAGANUZ ","OR HANER ","OR YEHUDA ","ORA ","ORANIM ","ORANIT ","OROT ","ORTAL ","OTNI'EL ","OZEM ","PA'AME TASHAZ ","PALMAHIM ","PARAN ","PARDES HANNA-KARKUR ","PARDESIYYA ","PAROD ","PATTISH ","PEDAYA ","PEDU'EL ","PEDUYIM ","PELEKH ","PENE HEVER ","PEQI'IN (BUQEI'A) ","PEQI'IN HADASHA ","PERAZON ","PERI GAN ","PESAGOT ","PETAH TIQWA ","PETAHYA ","PEZA'EL ","PORAT ","PORIYYA ILLIT ","PORIYYA-KEFAR AVODA ","PORIYYA-NEWE OVED ","QABBO'A ","QADDARIM ","QADIMA-ZORAN ","QALANSAWE ","QALYA ","QARNE SHOMERON ","QAWA'IN ","QAZIR ","QAZRIN ","QEDAR ","QEDMA ","QEDUMIM ","QELA ","QELAHIM ","QESARIYYA ","QESHET ","QETURA ","QEVUZAT YAVNE ","QIDMAT ZEVI ","QIDRON ","QIRYAT ANAVIM ","QIRYAT ARBA ","QIRYAT ATTA ","QIRYAT BIALIK ","QIRYAT EQRON ","QIRYAT GAT ","QIRYAT MAL'AKHI ","QIRYAT MOTZKIN ","QIRYAT NETAFIM ","QIRYAT ONO ","QIRYAT SHELOMO ","QIRYAT SHEMONA ","QIRYAT TIV'ON ","QIRYAT YAM ","QIRYAT YE'ARIM ","QIRYAT YE'ARIM(INSTI ","QOMEMIYYUT ","QORANIT ","QUDEIRAT AS-SANI ","RA'ANANA ","RAHAT ","RAMAT DAWID ","RAMAT GAN ","RAMAT HAKOVESH ","RAMAT HASHARON ","RAMAT HASHOFET ","RAMAT MAGSHIMIM ","RAMAT RAHEL ","RAMAT RAZI'EL ","RAMAT YISHAY ","RAMAT YOHANAN ","RAMAT ZEVI ","RAME ","RAMLA ","RAM-ON ","RAMOT ","RAMOT HASHAVIM ","RAMOT ME'IR ","RAMOT MENASHE ","RAMOT NAFTALI ","RANNEN ","RAQEFET ","RAS AL-EIN ","RAS ALI ","RAVID ","REGAVIM ","REGBA ","REHAN ","REHELIM ","REHOV ","REHOVOT ","REIHANIYYE ","RE'IM ","REINE ","REKHASIM ","RESHAFIM ","RETAMIM ","REVADIM ","REVAVA ","REVIVIM ","REWAHA ","REWAYA ","RIMMONIM ","RINNATYA ","RISHON LEZIYYON ","RISHPON ","RO'I ","ROSH HAAYIN ","ROSH PINNA ","ROSH ZURIM ","ROTEM ","RUAH MIDBAR ","RUHAMA ","RUMAT HEIB ","RUMMANE ","SA'AD ","SA'AR ","SAJUR ","SAKHNIN ","SAL'IT ","SALLAMA ","SAMAR ","SANDALA ","SAPPIR ","SARID ","SASA ","SAVYON ","SA'WA ","SAWA'ID (KAMANE) ","SAWA'ID(HAMRIYYE) ","SAYYID ","SEDE AVRAHAM ","SEDE BOQER ","SEDE DAWID ","SEDE ELI'EZER ","SEDE ELIYYAHU ","SEDE HEMED ","SEDE ILAN ","SEDE MOSHE ","SEDE NAHUM ","SEDE NEHEMYA ","SEDE NIZZAN ","SEDE TERUMOT ","SEDE UZZIYYAHU ","SEDE WARBURG ","SEDE YA'AQOV ","SEDE YIZHAQ ","SEDE YO'AV ","SEDE ZEVI ","SEDEROT ","SEDOT MIKHA ","SEDOT YAM ","SEGEV-SHALOM ","SEGULA ","SENIR ","SHA'AB ","SHA'AL ","SHA'ALVIM ","SHA'AR EFRAYIM ","SHA'AR HAAMAQIM ","SHA'AR HAGOLAN ","SHA'AR MENASHE ","SHA'ARE TIQWA ","SHADMOT DEVORA ","SHADMOT MEHOLA ","SHAFIR ","SHAHAR ","SHAHARUT ","SHALVA BAMIDBAR ","SHALWA ","SHAMERAT ","SHAMIR ","SHANI ","SHAQED ","SHARONA ","SHARSHERET ","SHAVE DAROM ","SHAVE SHOMERON ","SHAVE ZIYYON ","SHE'AR YASHUV ","SHEDEMA ","SHEFAR'AM ","SHEFAYIM ","SHEFER ","SHEIKH DANNUN ","SHEKHANYA ","SHELOMI ","SHELUHOT ","SHEQEF ","SHETULA ","SHETULIM ","SHEZAF ","SHEZOR ","SHIBBOLIM ","SHIBLI ","SHILAT ","SHILO ","SHIM'A ","SHIMSHIT ","SHIZZAFON ","SHLOMIT ","SHO'EVA ","SHOHAM ","SHOMERA ","SHOMERIYYA ","SHOQEDA ","SHORASHIM ","SHORESH ","SHOSHANNAT HAAMAQIM ","SHOSHANNAT HAAMAQIM( ","SHOVAL ","SHUVA ","SITRIYYA ","SUFA ","SULAM ","SUSEYA ","TAL SHAHAR ","TAL-EL ","TALME BILU ","TALME EL'AZAR ","TALME ELIYYAHU ","TALME YAFE ","TALME YEHI'EL ","TALME YOSEF ","TALMON ","TAMRA ","TAMRA (YIZRE'EL) ","TA'OZ ","TARABIN AS-SANI ","TARUM ","TAYIBE ","TAYIBE(BAEMEQ) ","TE'ASHUR ","TEFAHOT ","TEL ADASHIM ","TEL AVIV - YAFO ","TEL MOND ","TEL QAZIR ","TEL SHEVA ","TEL TE'OMIM ","TEL YIZHAQ ","TEL YOSEF ","TELALIM ","TELAMIM ","TELEM ","TENE ","TENUVOT ","TEQOA ","TEQUMA ","TIBERIAS ","TIDHAR ","TIFRAH ","TIMMORIM ","TIMRAT ","TIRAT KARMEL ","TIRAT YEHUDA ","TIRAT ZEVI ","TIRE ","TIROSH ","TOMER ","TRUMP HEIGHTS ","TUBA-ZANGARIYYE ","TUR'AN ","TUSHIYYA ","TUVAL ","UDIM ","UMM AL-FAHM ","UMM AL-QUTUF ","UMM BATIN ","UQBI (BANU UQBA) ","URIM ","USHA ","UZA ","UZEIR ","WARDON ","WERED YERIHO ","YA'AD ","YA'ARA ","YAD BINYAMIN ","YAD HANNA ","YAD HASHEMONA ","YAD MORDEKHAY ","YAD NATAN ","YAD RAMBAM ","YA'EL ","YAFI ","YAFIT ","YAGEL ","YAGUR ","YAHEL ","YAKHINI ","YANUH-JAT ","YANUV ","YAQIR ","YAQUM ","YARDENA ","YARHIV ","YARQONA ","YASHRESH ","YAS'UR ","YATED ","YAVNE ","YAVNE'EL ","YAZIZ ","YE'AF ","YEDIDA ","YEDIDYA ","YEHI'AM ","YEHUD-MONOSON ","YEROHAM ","YESHA ","YESODOT ","YESUD HAMA'ALA ","YEVUL ","YIF'AT ","YIFTAH ","YINNON ","YIRKA ","YIR'ON ","YISH'I ","YITAV ","YIZHAR ","YIZRE'EL ","YODEFAT ","YONATAN ","YOQNE'AM ILLIT ","YOQNE'AM(MOSHAVA) ","YOSHIVYA ","YOTVATA ","YUVAL ","YUVALIM ","ZABARGA ","ZAFRIRIM ","ZAFRIYYA ","ZANOAH ","ZARZIR ","ZAVDI'EL ","ZE'ELIM ","ZEFAT ","ZEKHARYA ","ZELAFON ","ZEMER ","ZERAHYA ","ZERU'A ","ZERUFA ","ZETAN ","ZIKHRON YA'AQOV ","ZIMRAT ","ZIPPORI ","ZIQIM ","ZIV'ON ","ZOFAR ","ZOFIT ","ZOFIYYA ","ZOHAR ","ZOR'A ","ZOVA ","ZUFIN ","ZUR HADASSA ","ZUR MOSHE ","ZUR NATAN ","ZUR YIZHAQ ","ZURI'EL ","ZURIT ","ZVIYYA"
  ];
  List<String> chosen_categories = [];
  final TextEditingController nameTextEditController = TextEditingController();
  final TextEditingController descriptionTextEditController =
  TextEditingController();

  File? _photo;
  final ImagePicker _picker = ImagePicker();
  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
      } else {
        // TODO:
        print('No image selected.');
      }
    });
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
      } else {
        // TODO:
        print('No image selected.');
      }
    });
  }

  Future uploadFile() async {
    if (_photo == null) return;
    final fileName = _photo!.path.split('/').last;
    final destination = 'items/$fileName';

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination);
      await ref.putFile(_photo!);
    } catch (e) {
      print('error occured');
    }
  }

  @override
  void initState() {
    super.initState();
    nameTextEditController.addListener(() {
      final String text = nameTextEditController.text.toLowerCase();
      nameTextEditController.value = nameTextEditController.value.copyWith(
        text: text,
        selection:
        TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });

    descriptionTextEditController.addListener(() {
      final String text = descriptionTextEditController.text.toLowerCase();
      descriptionTextEditController.value =
          descriptionTextEditController.value.copyWith(
            text: text,
            selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
            composing: TextRange.empty,
          );
    });
  }

  @override
  void dispose() {
    nameTextEditController.dispose();
    descriptionTextEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text('Add item')),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nameTextEditController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: "item's name"),
                maxLength: 50,
              ),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return locations
                      .where((String continent) => continent
                      .toLowerCase()
                      .startsWith(textEditingValue.text.toLowerCase()))
                      .toList();
                },
                displayStringForOption: (String option) => option,
                fieldViewBuilder: (BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextFormField(
                    controller: fieldTextEditingController,
                    decoration:
                    const InputDecoration(hintText: "item's location"),
                    focusNode: fieldFocusNode,
                  );
                },
                onSelected: (String selection) {
                  print('Selected: $selection');
                },
                optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<String> onSelected,
                    Iterable<String> options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      child: Container(
                        width: 300,
                        child: ListView.builder(
                          padding: EdgeInsets.all(10.0),
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);

                            return GestureDetector(
                              onTap: () {
                                onSelected(option);
                              },
                              child: ListTile(
                                title: Text(option,
                                    style:
                                    const TextStyle(color: Colors.white)),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: descriptionTextEditController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "item's description"),
                maxLength: 200,
                maxLines: 3,
              ),
              const SizedBox(
                height: 15,
              ),
              OutlinedButton(
                  onPressed: () {
                    _navigateAndDisplaySelection(context);
                  },
                  child: const Text(
                    "Choose item's categories",
                    style: TextStyle(fontSize: 18),
                  )),
              Wrap(
                direction: Axis.horizontal,
                spacing: 5,
                children:
                chosen_categories.map((e) => Chip(label: Text(e))).toList(),
              ),
              const Text(
                "Upload an image for the item:",
                style: TextStyle(fontSize: 17),
              ),
              const SizedBox(
                height: 15,
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    _showPicker(context);
                  },
                  child: CircleAvatar(
                    radius: 26,
                    child: _photo != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.file(
                        _photo!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.fitHeight,
                      ),
                    )
                        : Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(45)),
                      width: 45,
                      height: 45,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: () {
                  Item newItem = Item(
                      name: nameTextEditController.text,
                      description: descriptionTextEditController.text,
                      location: 'Haifa',
                      categories: chosen_categories, image: _photo!.path.split('/').last);

                  FirestoreItems.instance().addNewItem(newItem.toJson());
                  uploadFile();
                  Navigator.pop(context);
                },
                child: const Text("Submit"),
              )
            ],
          ),
        ));
  }

  Future<void> _navigateAndDisplaySelection(BuildContext context) async {
    // TODO: more elegant
    final chosen_categories_result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CategoryScreen()),
    );

    setState(() {
      if (chosen_categories_result != null) {
        chosen_categories = chosen_categories_result;
      }
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Gallery'),
                      onTap: () {
                        imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('Camera'),
                    onTap: () {
                      imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
