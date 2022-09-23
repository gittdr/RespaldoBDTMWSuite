SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[translate_sp] (@intext varchar (256) , @language varchar (64), @outtext varchar (256) output, @qualifier varchar (6) = '' output ) 
AS


if upper (@language) = 'ENGLISH'
	set @outtext = ltrim (rtrim(@intext)) + ' '

if upper (@language) = 'SPANISH'
begin
set @qualifier = ' y ' 
set @outtext = 
	case Upper (@intext) 
		when 'ONE' then  'Uno'
		when 'TWO' then  'Dos'
		when 'THREE' Then 'Tres'
		when 'FOUR' then  'Quatro'
		when 'FIVE' then 'Cinco'
		when 'SIX' then 'Seis'
		when 'SEVEN' Then  'Siete'
		when 'EIGHT' then  'Ocho'
		When 'NINE' then  'Nueve'
		When 'TEN' then  'Diez'
		when 'ELEVEN' then  'Once'
		when 'TWELVE' then  'Doce'
		when 'THIRTEEN' then  'Trece'
		when 'FOURTEEN' then  'Catorce'
		when 'FIFTEEN' then  'Quince'
		when 'SIXTEEN' then  'Dieciseis'
		when 'SEVENTEEN' then 'Diecisiete'
		when 'EIGHTEEN' then  'Dieciocho'
		when 'NINETEN' then  'Diecinueve'
		when 'TWENTY' then  'Viente'
		when 'THIRTY' then  'Trienta'
		when 'FORTY' then  'Cuarenta'
		when 'FIFTY' then  'Cincuenta'
		when 'SIXTY' then  'Sesenta' 
		when 'SEVENTY' then  'Setenta'
		when 'EIGHTY' then  'Ochenta'
 		when 'NINETY' then   'Noventa'
		WHEN 'HUNDRED' then  'Ciento'
		WHEN 'THOUSAND' then  'Mil'
		WHEN 'MILLION' then  'Milliones'
		else 'NOTHING'
	end
end
if upper (@language) = 'Dutch'
begin
set @qualifier = 'en' 
set @outtext = 
	case Upper (@intext) 
		when 'ONE' then  'Een'
		when 'TWO' then  'Twee'
		when 'THREE' Then 'Drie'
		when 'FOUR' then  'Vier'
		when 'FIVE' then 'Vijf'
		when 'SIX' then 'Zes'
		when 'SEVEN' Then  'Zeven'
		when 'EIGHT' then  'Acht'
		When 'NINE' then  'Negen'
		When 'TEN' then  'Tien'
		when 'ELEVEN' then  'Elf'
		when 'TWELVE' then  'Twaalf'
		when 'THIRTEEN' then  'Dertien'
		when 'FOURTEEN' then  'Veertien'
		when 'FIFTEEN' then  'Vijftien'
		when 'SIXTEEN' then  'Zestien'
		when 'SEVENTEEN' then 'Zeventien'
		when 'EIGHTEEN' then  'Achttien'
		when 'NINETEN' then  'Negentien'
		when 'TWENTY' then  'Twintig'
		when 'THIRTY' then  'Dertig'
		when 'FORTY' then  'Veertig'
		when 'FIFTY' then  'Vijftig'
		when 'SIXTY' then  'Zestig' 
		when 'SEVENTY' then  'Zeventig'
		when 'EIGHTY' then  'Tachtig'
 		when 'NINETY' then   'Negtig'
		WHEN 'HUNDRED' then  'Honderd'
		WHEN 'THOUSAND' then  'Duizend'
		WHEN 'MILLION' then  'Miljoen'
		else 'NOTHING'
	end
end
if upper (@language) = 'German'
begin
set @qualifier = 'und' 
set @outtext = 
	case Upper (@intext) 
		when 'ONE' then  'Ein'
		when 'TWO' then  'Twei'
		when 'THREE' Then 'Drie'
		when 'FOUR' then  'Vier'
		when 'FIVE' then 'Funf'
		when 'SIX' then 'Sechs'
		when 'SEVEN' Then  'Seiben'
		when 'EIGHT' then  'Acht'
		When 'NINE' then  'Neun'
		When 'TEN' then  'Aein'
		when 'ELEVEN' then  'Elf'
		when 'TWELVE' then  'Tweif'
		when 'THIRTEEN' then  'Dreizehn'
		when 'FOURTEEN' then  'Vierzehn'
		when 'FIFTEEN' then  'Funfzehn'
		when 'SIXTEEN' then  'Sechzehn'
		when 'SEVENTEEN' then 'Seibzehn'
		when 'EIGHTEEN' then  'Achtzehn'
		when 'NINETEN' then  'Neunzehn'
		when 'TWENTY' then  'Zwanzig'
		when 'THIRTY' then  'Dreissig'
		when 'FORTY' then  'Vierzig'
		when 'FIFTY' then  'Funfzig'
		when 'SIXTY' then  'Sechzig' 
		when 'SEVENTY' then  'Zeibzig'
		when 'EIGHTY' then  'Achtzig'
 		when 'NINETY' then   'Neunzig'
		WHEN 'HUNDRED' then  'Hundert'
		WHEN 'THOUSAND' then  'Tausend'
		WHEN 'MILLION' then  'Million'
	end
end

if upper (@language) = 'FRENCH'
begin
set @qualifier = '-' 
set @outtext = 
	case Upper (@intext) 
		when 'ONE' then  'Un'
		when 'TWO' then  'Deux'
		when 'THREE' Then 'Trois'
		when 'FOUR' then  'Quatre'
		when 'FIVE' then 'Cinq'
		when 'SIX' then 'Six'
		when 'SEVEN' Then  'Sept'
		when 'EIGHT' then  'Huit'
		When 'NINE' then  'Neuf'
		When 'TEN' then  'Dix'
		when 'ELEVEN' then  'Onze'
		when 'TWELVE' then  'Douze'
		when 'THIRTEEN' then  'Treize'
		when 'FOURTEEN' then  'Quatorze'
		when 'FIFTEEN' then  'Quinze'
		when 'SIXTEEN' then  'Sieze'
		when 'SEVENTEEN' then 'Dix-Sept'
		when 'EIGHTEEN' then  'Dix-Huit'
		when 'NINETEN' then  'Dix-Nuef'
		when 'TWENTY' then  'Vingt'
		when 'THIRTY' then  'Trente'
		when 'FORTY' then  'Quarante'
		when 'FIFTY' then  'Cinquante'
		when 'SIXTY' then  'Soixante' 
		when 'SEVENTY' then  'Soixante-Dix'
		when 'EIGHTY' then  'Quatre-Vingts'
 		when 'NINETY' then   'Quatre-Vingt-Dix'
		WHEN 'HUNDRED' then  'Cent'
		WHEN 'THOUSAND' then  'Mille'
		WHEN 'MILLION' then  'Million'
	end
end
GO
GRANT EXECUTE ON  [dbo].[translate_sp] TO [public]
GO
