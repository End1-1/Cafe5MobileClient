final Map<String, String> vals = {
  'new task': 'Նոր առաջադրանք',
  'select task': 'Ընտրեք առաջադրանք',
  'edit task': 'Խմբագրել առաջադրանք',
  'workshops': 'Արտադրամասեր',
  'current tasks': 'Ընդացիկ առաջադրանքներ',
  'no data': 'Տվյալներ չկան',
  'workshop': 'Արտադրամաս',
  'date':'Ամսաթիվ',
  'stage':'Փուլ',
  'goods code':'Արանքի կոդ',
  'qty':'Քնկ',
  'change workshop?':'Փոխել՞ արտադրամասը',
  'date created':'Ստեղծման ամսաթիվ',
  'time created':'Ստեղծման ժամ',
  'total qty':'Ընդհանուր քանակ',
  'create':'Ստեղծել',
  'activate state':'Փոխել փուլը',
  'execute':'Կատարել',
  'please, create new task':'Գրանցեք նոր առաջադրանք',
  'empty process':'Դատարկ գործողություն',
  'product is not selected':'Արտադրանքը նշված չէ',
  'workshop is not selected':'Արտադրամասը նշված չէ',
  'stage is not selected':'Փուլը նշված չէ',
  'input right quantity':'Մուտքագրեք ճիշտ քանակ',
  'nothing selected':'ուչինչ նշված չէ',
  'change current state?':'Փոխել՞ փուլը',
  'save': 'Պահպանել',
  'unknown':'Անհայտ',
  'qty':'Քնկ',
  'ready':'Պատրաստ',
  'out':'Ելք'
};

String tr(String s) {
  return Translator.tr(s);
}

class Translator {
  static String tr(String s) {
    if (vals.containsKey(s.toLowerCase())) {
      return vals[s.toLowerCase()]!;
    }
    return s;
  }
}