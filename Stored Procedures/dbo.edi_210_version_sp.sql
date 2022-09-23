SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_210_version_sp] 
	@invoice_number varchar( 12 )

 as
/*
  PTS 10266 3/20/01 allow for delay between edi 210 documents

*/
declare @EDI210Ver varchar(60), @delaylength char(9),@delayseconds varchar(2)


select @EDI210Ver=isnull(gi_string1,'1.0')
	from generalinfo
	where gi_name='EDI210Ver'

SELECT @delaylength = '000:00:'
SELECT @delayseconds = SUBSTRING(ISNULL(gi_string1,'00'),1,2)
	from generalinfo
	where gi_name='EDISecondsWait'

IF @delayseconds > '59' SELECT delayseconds = '59'  -- do not allow 99

SELECT @delaylength = 
	CASE LEN(@delayseconds)
	WHEN 2 THEN SUBSTRING(@delaylength,1,7) + @delayseconds
	WHEN 1 THEN SUBSTRING(@delaylength,1,7) + '0'+ @delayseconds
	END

--insert into tts_errorlog(err_batch,err_user_id,err_message) values (999,'dpete',@delaylength+'/'+@delayseconds+'/')
IF @delaylength <> '000:00:00'
   WAITFOR DELAY @delaylength
    
--insert into tts_errorlog(err_batch,err_user_id,err_message) values (999,'dpete','back')
if @EDI210Ver='3.4' -- version 3.4
	exec edi_210_all_34_sp @invoice_number
else if @EDI210Ver='3.9' -- version 3.9
	exec edi_210_all_39_sp @invoice_number
else -- either not specified, use latest
	exec edi_210_all_39_sp @invoice_number

GO
GRANT EXECUTE ON  [dbo].[edi_210_version_sp] TO [public]
GO
