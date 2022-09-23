SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_214_record_id_6_10_sp] 
	@invoice_number varchar( 12 ),
	@trpid varchar(20)
 as

declare @emptystring varchar(79)
select @emptystring=''

INSERT edi_214 (data_col, trp_id) 
SELECT 
data_col = '6' +				-- Record ID
'10' +						-- Record Version
@emptystring +	replicate(' ',1-datalength(@emptystring)) +	-- OSD code
@emptystring +	replicate(' ',3-datalength(@emptystring)) +	-- quantity qualifier
replicate('0',6-datalength(@emptystring)) + @emptystring,	-- quantity
trp_id=@trpid


GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_6_10_sp] TO [public]
GO
