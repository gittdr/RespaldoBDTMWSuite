SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[tmw_legstopslate_fn] (@lgh_number int)
RETURNS varchar(1000)
AS
BEGIN
	declare @stoplist varchar(2000)
	declare @Table table
		(StopNumber		varchar(10),
		HoursLate		varchar(10),
		Seperator		varchar(2))

	insert @Table  SELECT cast(stp_mfh_sequence as char(10)) 'StopNumber', cast(datediff(hour, CURRENT_TIMESTAMP, stp_schdtlatest) * -1 as char(10))  'HoursLate', '/n' 'Seperator'
							FROM stops
							WHERE ( lgh_number = @lgh_number and CURRENT_TIMESTAMP > stp_schdtlatest and stp_status <> 'DNE')
							Order By stp_mfh_sequence
select @stoplist = ''

SELECT @stoplist = @stoplist +  'Stop: ' + ltrim(rtrim(StopNumber)) + ' ' + 'Late: ' + ltrim(rtrim(HoursLate)) + ' Hr(s) ' + ltrim(rtrim(Seperator))  from @table

return @stoplist
END
GO
GRANT EXECUTE ON  [dbo].[tmw_legstopslate_fn] TO [public]
GO
