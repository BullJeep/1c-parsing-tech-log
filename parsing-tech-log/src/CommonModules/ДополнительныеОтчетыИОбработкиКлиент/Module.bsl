

// Открывает форму с доступными командами.
//
// Параметры:
//   ПараметрКоманды            - Передается "как есть" из параметров обработчика команды.
//   ПараметрыВыполненияКоманды - Передается "как есть" из параметров обработчика команды.
//   Вид - Строка - Вид обработки, который можно получить из серии функций:
//       ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработки<...>().
//   ИмяРаздела - Строка - Имя раздела командного интерфейса, из которого вызывается команда.
//
Процедура ОткрытьФормуКомандДополнительныхОтчетовИОбработок(ПараметрКоманды, ПараметрыВыполненияКоманды, Вид, ИмяРаздела = "") Экспорт
	
	ОбъектыНазначения = Новый СписокЗначений;
	Если ТипЗнч(ПараметрКоманды) = Тип("Массив") Тогда // назначаемая обработка
		ОбъектыНазначения.ЗагрузитьЗначения(ПараметрКоманды);
	КонецЕсли;
	
	Параметры = Новый Структура("ОбъектыНазначения, Вид, ИмяРаздела, РежимОткрытияОкна");
	Параметры.ОбъектыНазначения = ОбъектыНазначения;
	Параметры.Вид = Вид;
	Параметры.ИмяРаздела = ИмяРаздела;
	Параметры.РежимОткрытияОкна = РежимОткрытияОкнаФормы.БлокироватьОкноВладельца;
	
	Если ТипЗнч(ПараметрыВыполненияКоманды.Источник) = Тип("УправляемаяФорма") Тогда // назначаемая обработка
		Параметры.Вставить("ИмяФормы", ПараметрыВыполненияКоманды.Источник.ИмяФормы);
	КонецЕсли;
	
	ОткрытьФорму(
		"ОбщаяФорма.ДополнительныеОтчетыИОбработки", 
		Параметры,
		ПараметрыВыполненияКоманды.Источник);
	
КонецПроцедуры


#Область СлужебныеПроцедурыИФункции

// Выводит оповещение перед запуском команды.
Процедура ПоказатьОповещениеПриВыполненииКоманды(ВыполняемаяКоманда) Экспорт
	Если ВыполняемаяКоманда.ПоказыватьОповещение Тогда
		ПоказатьОповещениеПользователя(НСтр("ru = 'Команда выполняется...'"), , ВыполняемаяКоманда.Представление);
	КонецЕсли;
КонецПроцедуры

// Открывает форму обработки.
Процедура ВыполнитьОткрытиеФормыОбработки(ВыполняемаяКоманда, Форма, ОбъектыНазначения) Экспорт
	ПараметрыОбработки = Новый Структура("ИдентификаторКоманды, ДополнительнаяОбработкаСсылка, ИмяФормы, КлючСессии");
	ПараметрыОбработки.ИдентификаторКоманды          = ВыполняемаяКоманда.Идентификатор;
	ПараметрыОбработки.ДополнительнаяОбработкаСсылка = ВыполняемаяКоманда.Ссылка;
	ПараметрыОбработки.ИмяФормы                      = ?(Форма = Неопределено, Неопределено, Форма.ИмяФормы);
	ПараметрыОбработки.КлючСессии = ВыполняемаяКоманда.Ссылка.УникальныйИдентификатор();
	
	Если ТипЗнч(ОбъектыНазначения) = Тип("Массив") Тогда
		ПараметрыОбработки.Вставить("ОбъектыНазначения", ОбъектыНазначения);
	КонецЕсли;
	
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		ВнешняяОбработка = ДополнительныеОтчетыИОбработкиВызовСервера.ПолучитьОбъектВнешнейОбработки(ВыполняемаяКоманда.Ссылка);
		ФормаОбработки = ВнешняяОбработка.ПолучитьФорму(, Форма);
		Если ФормаОбработки = Неопределено Тогда
			ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Для отчета или обработки ""%1"" не назначена основная форма,
				|или основная форма не предназначена для запуска в обычном приложении.
				|Команда ""%2"" не может быть выполнена.'"),
				Строка(ВыполняемаяКоманда.Ссылка),
				ВыполняемаяКоманда.Представление);
		КонецЕсли;
		ФормаОбработки.Открыть();
		ФормаОбработки = Неопределено;
	#Иначе
		ИмяОбработки = ДополнительныеОтчетыИОбработкиВызовСервера.ПодключитьВнешнююОбработку(ВыполняемаяКоманда.Ссылка);
		Если ВыполняемаяКоманда.ЭтоОтчет Тогда
			ОткрытьФорму("ВнешнийОтчет."+ ИмяОбработки +".Форма", ПараметрыОбработки, Форма);
		Иначе
			ОткрытьФорму("ВнешняяОбработка."+ ИмяОбработки +".Форма", ПараметрыОбработки, Форма);
		КонецЕсли;
	#КонецЕсли
КонецПроцедуры

// Выполняет клиентский метод обработки.
Процедура ВыполнитьКлиентскийМетодОбработки(ВыполняемаяКоманда, Форма, ОбъектыНазначения) Экспорт
	
	ПоказатьОповещениеПриВыполненииКоманды(ВыполняемаяКоманда);
	
	ПараметрыОбработки = Новый Структура("ИдентификаторКоманды, ДополнительнаяОбработкаСсылка, ИмяФормы");
	ПараметрыОбработки.ИдентификаторКоманды          = ВыполняемаяКоманда.Идентификатор;
	ПараметрыОбработки.ДополнительнаяОбработкаСсылка = ВыполняемаяКоманда.Ссылка;
	ПараметрыОбработки.ИмяФормы                      = ?(Форма = Неопределено, Неопределено, Форма.ИмяФормы);;
	
	Если ТипЗнч(ОбъектыНазначения) = Тип("Массив") Тогда
		ПараметрыОбработки.Вставить("ОбъектыНазначения", ОбъектыНазначения);
	КонецЕсли;
	
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		ВнешняяОбработка = ДополнительныеОтчетыИОбработкиВызовСервера.ПолучитьОбъектВнешнейОбработки(ВыполняемаяКоманда.Ссылка);
		ФормаОбработки = ВнешняяОбработка.ПолучитьФорму(, Форма);
		Если ФормаОбработки = Неопределено Тогда
			ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Для отчета или обработки ""%1"" не назначена основная форма,
				|или основная форма не предназначена для запуска в обычном приложении.
				|Команда ""%2"" не может быть выполнена.'"),
				Строка(ВыполняемаяКоманда.Ссылка),
				ВыполняемаяКоманда.Представление);
		КонецЕсли;
	#Иначе
		ИмяОбработки = ДополнительныеОтчетыИОбработкиВызовСервера.ПодключитьВнешнююОбработку(ВыполняемаяКоманда.Ссылка);
		Если ВыполняемаяКоманда.ЭтоОтчет Тогда
			ФормаОбработки = ПолучитьФорму("ВнешнийОтчет."+ ИмяОбработки +".Форма", ПараметрыОбработки, Форма);
		Иначе
			ФормаОбработки = ПолучитьФорму("ВнешняяОбработка."+ ИмяОбработки +".Форма", ПараметрыОбработки, Форма);
		КонецЕсли;
	#КонецЕсли
	
	Если ВыполняемаяКоманда.Вид = ПредопределенноеЗначение("Перечисление.ВидыДополнительныхОтчетовИОбработок.ДополнительнаяОбработка")
		Или ВыполняемаяКоманда.Вид = ПредопределенноеЗначение("Перечисление.ВидыДополнительныхОтчетовИОбработок.ДополнительныйОтчет") Тогда
		
		ФормаОбработки.ВыполнитьКоманду(ВыполняемаяКоманда.Идентификатор);
		
	ИначеЕсли ВыполняемаяКоманда.Вид = ПредопределенноеЗначение("Перечисление.ВидыДополнительныхОтчетовИОбработок.СозданиеСвязанныхОбъектов") Тогда
		
		СозданныеОбъекты = Новый Массив;
		
		ФормаОбработки.ВыполнитьКоманду(ВыполняемаяКоманда.Идентификатор, ОбъектыНазначения, СозданныеОбъекты);
		
		ТипыСозданныхОбъектов = Новый Массив;
		
		Для Каждого СозданныйОбъект Из СозданныеОбъекты Цикл
			Тип = ТипЗнч(СозданныйОбъект);
			Если ТипыСозданныхОбъектов.Найти(Тип) = Неопределено Тогда
				ТипыСозданныхОбъектов.Добавить(Тип);
			КонецЕсли;
		КонецЦикла;
		
		Для Каждого Тип Из ТипыСозданныхОбъектов Цикл
			ОповеститьОбИзменении(Тип);
		КонецЦикла;
		
	ИначеЕсли ВыполняемаяКоманда.Вид = ПредопределенноеЗначение("Перечисление.ВидыДополнительныхОтчетовИОбработок.ПечатнаяФорма") Тогда
		
		ФормаОбработки.Печать(ВыполняемаяКоманда.Идентификатор, ОбъектыНазначения);
		
	ИначеЕсли ВыполняемаяКоманда.Вид = ПредопределенноеЗначение("Перечисление.ВидыДополнительныхОтчетовИОбработок.ЗаполнениеОбъекта") Тогда
		
		ФормаОбработки.ВыполнитьКоманду(ВыполняемаяКоманда.Идентификатор, ОбъектыНазначения);
		
		ТипыИзмененныхОбъектов = Новый Массив;
		
		Для Каждого ИзмененныйОбъект Из ОбъектыНазначения Цикл
			Тип = ТипЗнч(ИзмененныйОбъект);
			Если ТипыИзмененныхОбъектов.Найти(Тип) = Неопределено Тогда
				ТипыИзмененныхОбъектов.Добавить(Тип);
			КонецЕсли;
		КонецЦикла;
		
		Для Каждого Тип Из ТипыИзмененныхОбъектов Цикл
			ОповеститьОбИзменении(Тип);
		КонецЦикла;
		
	ИначеЕсли ВыполняемаяКоманда.Вид = ПредопределенноеЗначение("Перечисление.ВидыДополнительныхОтчетовИОбработок.Отчет") Тогда
		
		ФормаОбработки.ВыполнитьКоманду(ВыполняемаяКоманда.Идентификатор, ОбъектыНазначения);
		
	КонецЕсли;
	
	ФормаОбработки = Неопределено;
	
КонецПроцедуры

#КонецОбласти