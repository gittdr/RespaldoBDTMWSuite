SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[edi_214_record_id_4_34_sp] 
	@ord_hdrnumber integer, 
	@table varchar(20),
	@key integer,
	@trpid varchar(20),
	@docid varchar(30)
 as
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
	-- pts 7526 4/4/00 add ref numbers at appropriate locations
	-- pts10311 6/25/02 make v3.4 work in PS v2001,2002
 * 11/30/2007.01 ? PTS40464 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

declare @billto 	varchar(8)

select @billto=ord_billto from orderheader where ord_hdrnumber=@ord_hdrnumber

CREATE TABLE #reftemp (
	ref_type varchar(6) NULL,
	edicode varchar(3) NULL,
	ref_number varchar(20) NULL
)

INSERT #reftemp
SELECT ref_type,
	UPPER(ISNULL(edicode,'ZZ ')),
	ref_number
FROM labelfile l RIGHT OUTER JOIN referencenumber r ON (l.abbr = r.ref_type and l.labeldefinition = 'ReferenceNumbers')
WHERE r.ref_table = @table
AND   r.ref_tablekey = @key
AND   r.ref_type in (SELECT prq_reftype
		FROM process_requirements
		WHERE prq_billto = @billto
		AND PRQ_reftable = @table
		AND prq_214export = 'Y')
--AND l.labeldefinition = 'ReferenceNumbers'
--AND l.abbr =* r.ref_type

-- create #4 misc records 
INSERT edi_214 (data_col,trp_id, doc_id)
SELECT datacol = '4' +
	'34' +
	'REF' +
	edicode + replicate(' ',3-datalength(edicode)) +
	ref_number + replicate (' ',76-datalength(ref_number)),
	trp_id = @trpid, doc_id = @docid
FROM #reftemp




GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_4_34_sp] TO [public]
GO
