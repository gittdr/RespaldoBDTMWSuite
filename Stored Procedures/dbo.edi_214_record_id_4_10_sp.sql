SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_214_record_id_4_10_sp] 
	@invoice_number varchar( 12 ),
	@trpid varchar(20)
 as

declare @emptystring varchar(79)
select @emptystring=' '

INSERT edi_214 (data_col, trp_id) 
SELECT
data_col = '4' +				-- Record ID
'10' +						-- Record Version
@emptystring +	replicate(' ',3-datalength(@emptystring)) +	-- misc data type
@emptystring +	replicate(' ',79-datalength(@emptystring)),	-- misc data
trp_id=@trpid

GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_4_10_sp] TO [public]
GO
