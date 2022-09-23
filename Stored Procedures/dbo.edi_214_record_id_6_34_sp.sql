SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*

pts10311 make v3.4 ouput work in PS v2001,2002 for manual 214
*/
CREATE PROCEDURE [dbo].[edi_214_record_id_6_34_sp] 
		@trpid varchar(20),
	@docid varchar(30)
 as

declare @emptystring varchar(79)
select @emptystring=''

INSERT edi_214 (data_col,trp_id,doc_id)
SELECT 
data_col = '6' +				-- Record ID
'34' +						-- Record Version
@emptystring +	replicate(' ',1-datalength(@emptystring)) +	-- OSD code
@emptystring +	replicate(' ',3-datalength(@emptystring)) +	-- quantity qualifier
replicate('0',6-datalength(@emptystring)) + @emptystring,	-- quantity
trp_id=@trpid, doc_id = @docid

GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_6_34_sp] TO [public]
GO
