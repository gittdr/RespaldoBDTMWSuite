SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [dbo].[TMWSSRS_fcn_SSRSLabelFileCheck]
(	
	@tablename varchar(25),
	@keyfieldname varchar(25),
	@labeldefinition varchar(20),
	@fieldname varchar(25)
)

returns varchar(MAX)

as
/*
Function TMWSSRS_fcn_referencenumberstype
11/5/2014 New version 
JR
Build a string to do an exec SQL in the calling proc, resulting code like so:

insert into @Quality
select @TableName,
0,
'car_id',
car_id,
'CarManager',
ISNULL((select top 1 userlabelname from labelfile with(nolock) where labeldefinition ='CarManager'),''),
'car_manager',
car_manager
from carrier car with(nolock)
WHERE car.car_manager
not in (
	select abbr 
	from labelfile with(nolock)
	where labeldefinition='CarManager')
OR car.car_manager=''
or car.car_manager is null ;

*/

begin
	--declare @num varchar(12)
	DECLARE @ReturnString varchar(8000)
	
	if @tablename = 'Orderheader' or @tablename = 'Legheader' or @tablename = 'Invoiceheader'
		BEGIN
			set @ReturnString = 'select ' + CHAR(39) + @tablename  + CHAR(39) + ', '
			+ '0, '
			+ char(39) + @keyfieldname + char(39) + ', '
			+ '[' + (@keyfieldname) + '], ' +
			case @tablename
			when 'Orderheader' then CHAR(39) + 'ord_start' + CHAR(39)  + ', '
				+ '[ord_completiondate], ' 
			when 'Legheader' then CHAR(39) + 'lgh_startdate' + CHAR(39)  + ', '
				+ '[lgh_enddate], ' 
			when 'Invoiceheader' then CHAR(39) + 'ivh_shipdate' + CHAR(39)  + ', '
				+ '[ivh_deliverydate], ' 	
			end 
			+ CHAR(39) + (@labeldefinition) + CHAR(39) + ', '
			+ ' ISNULL((select top 1 userlabelname from labelfile with(nolock) where labeldefinition =' 
			+ CHAR(39) + (@labeldefinition) + CHAR(39) + '),' + CHAR(39) + CHAR(39) + '), '
			+ CHAR(39) + @fieldname + CHAR(39) + ', '
			+ '[' + (@fieldname)  + '] ' 
			+ ' from ' + @tablename + ' with(nolock) ' 	+ ' where ' + @fieldname + ' not in ' 
			+ '(select abbr from labelfile with(nolock) where labeldefinition=' + CHAR(39) + (@labeldefinition) + CHAR(39) + ') '
			+ ' or ' + '[' + (@fieldname)  + '] '  + '=' + CHAR(39) + CHAR(39)
			+ ' or ' + '[' + (@fieldname)  + '] '  + ' is null ;'
		
		END
	ELSE 
		BEGIN
			set @ReturnString = 'select ' + CHAR(39) + @tablename  + CHAR(39) + ', '
			+ '0, '
			+ char(39) + @keyfieldname + char(39) + ', '
			+ '[' + (@keyfieldname) + '], '
			+ CHAR(39) + (@labeldefinition) + CHAR(39) + ', '
			+ ' ISNULL((select top 1 userlabelname from labelfile with(nolock) where labeldefinition =' 
			+ CHAR(39) + (@labeldefinition) + CHAR(39) + '),' + CHAR(39) + CHAR(39) + '), '
			+ CHAR(39) + @fieldname + CHAR(39) + ', '
			+ '[' + (@fieldname)  + '] ' 
			+ ' from ' + @tablename + ' with(nolock) ' 	+ ' where ' + @fieldname + ' not in ' 
			+ '(select abbr from labelfile with(nolock) where labeldefinition=' + CHAR(39) + (@labeldefinition) + CHAR(39) + ') '
			+ ' or ' + '[' + (@fieldname)  + '] '  + '=' + CHAR(39) + CHAR(39)
			+ ' or ' + '[' + (@fieldname)  + '] '  + ' is null ;'
		END

RETURN ISNULL(@ReturnString,'')

end


GO
GRANT EXECUTE ON  [dbo].[TMWSSRS_fcn_SSRSLabelFileCheck] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TMWSSRS_fcn_SSRSLabelFileCheck] TO [public]
GO
