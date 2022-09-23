SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/***************************Modification Log***************************************
				      *
***********************************************************************************/

CREATE PROCEDURE [dbo].[edi_214_record_id_4_39_sp]
	@ord_hdrnumber integer, 
	@table varchar(20),
	@key integer,
	@trpid varchar(20), 
	@docid varchar(30),
-- PTS 16223 -- BL 
	@company_id varchar(8)
 as
  /**
 * 
 * NAME:
 * dbo.edi_214_record_id_4_39_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure creates the miscellaneous "4" records for the EDI 214 document.  
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @ord_hdrnumber, integer, input, null;
 *       This parameter indicates the invoice number for which the records are being created.
 * 002 - @table, varchar(20), input, null;
 *       This parameter indicates the type pof reference number for which the record is being created.
 * 003 - @trpid, varchar(20), input, null;
 *       This parameter indicates the trading partner for which the EDI 214 is being
 *       created.
 * 004 - @docid, varchar(30), input, null;
 *		 This parameter indicates the document id for the individual edi 214 transaction.
 * 005 - @company_id varchar(8), input null;
 *	     This parameter indicates the company id for which the reference record is being created.
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * CalledBy001 ? edi_214_record_id_1_39_sp
 * CalledBy002 ? edi_214_record_id_3_39_sp

 * 
 * REVISION HISTORY:
 * 03/1/2005.01 ? PTSnnnnn - AuthorName ? Revision Description
 *	 dpete pts 7276 pull refs for level needed								  *
 *	Aross PTS 28633 Add reference number setup by trading partner, also allow for reference #'s up to 30 characters	
 * 10/18/2005.03 - PTS30167 - A.Rossman - Allow null values on reference number temp table.
 *
 **/
 

declare @billto 	varchar(8)

DECLARE @gps_location varchar(30), 
	@start_location integer, 
	@end_location integer, 
	@driver_id varchar(8)

--19520 ntk Custom sorting of references.
declare @customsort varchar(60), @startpos int, @nextpos int, @nextreftype varchar(6)
select @customsort = gi_String1, @startpos = 1, @nextpos = 1 from generalinfo where gi_name = 'EDIRefCustomSort'

-- PTS 16223 -- BL 
--select @billto=ord_billto from orderheader where ord_hdrnumber=@ord_hdrnumber

CREATE TABLE #reftemp (
	ref_type varchar(6) NULL,
	edicode varchar(3) NULL,
	ref_number varchar(30) NULL,
	ref_sequence int NULL
)

-- PTS 16223 -- BL (start)
--   (allow for 'All' option for ref_type and ref_table on EDI_214_profile table)
-- INSERT #reftemp
-- SELECT ref_type,
-- 	UPPER(ISNULL(edicode,'ZZ ')),
-- 	ref_number
-- FROM referencenumber r,labelfile l
-- WHERE r.ref_table = @table
-- AND   r.ref_tablekey = @key
-- AND   r.ref_type in (SELECT prq_reftype
-- 		FROM process_requirements
-- 		WHERE prq_billto = @billto
-- 		AND PRQ_reftable = @table
-- 		AND prq_214export = 'Y')
-- AND l.labeldefinition = 'ReferenceNumbers'
-- AND l.abbr =* r.ref_type
INSERT #reftemp
   SELECT ref_type,
	edicode = Case IsNull(edicode,UPPER(left(ref_type,3)))								  --AROSS PTS 28633
				WHen ' '  
				then UPPER(left(ref_type,3))
				else 
				IsNull(edicode,UPPER(left(ref_type,3)))
			  End,	
	ref_number,
	ref_sequence
   FROM referencenumber ref, process_requirements pr, labelfile lbl
   WHERE ref.ref_type = pr.prq_reftype
     AND ref.ref_table = pr.prq_reftable
     AND ref.ref_type = lbl.abbr
     AND lbl.labeldefinition = 'ReferenceNumbers'
     AND pr.prq_214export = 'Y'
     AND pr.prq_reftable = @table
     AND pr.prq_billto = @company_id
     AND ref.ref_tablekey = @key
 UNION
   SELECT ref_type,
	edicode = Case IsNull(edicode,UPPER(left(ref_type,3)))								  --AROSS PTS 28633
				WHen ' '  
				then UPPER(left(ref_type,3))
				else 
				IsNull(edicode,UPPER(left(ref_type,3)))
			  End,	
	ref_number,
	ref_sequence
   FROM referencenumber ref, process_requirements pr, labelfile lbl
   WHERE ref.ref_type = pr.prq_reftype
     AND ref.ref_type = lbl.abbr
     AND pr.prq_reftable = '^all^'
     AND lbl.labeldefinition = 'ReferenceNumbers'
     AND pr.prq_214export = 'Y'
     AND ref.ref_table = @table
     AND pr.prq_billto = @company_id
     AND ref.ref_tablekey = @key
 UNION
   SELECT ref_type,
	edicode = Case IsNull(edicode,UPPER(left(ref_type,3)))								  --AROSS PTS 28633
				WHen ' '  
				then UPPER(left(ref_type,3))
				else 
				IsNull(edicode,UPPER(left(ref_type,3)))
			  End,	
	ref_number,
	ref_sequence
   FROM referencenumber ref, process_requirements pr, labelfile lbl
   WHERE ref.ref_table = pr.prq_reftable
     AND ref.ref_type = lbl.abbr
     AND pr.prq_reftype = '^ALL^'
     AND lbl.labeldefinition = 'ReferenceNumbers'
     AND pr.prq_214export = 'Y'
     AND pr.prq_reftable = @table
     AND pr.prq_billto = @company_id
     AND ref.ref_tablekey = @key
 UNION
   SELECT ref_type,
	edicode = Case IsNull(edicode,UPPER(left(ref_type,3)))								  --AROSS PTS 28633
				WHen ' '  
				then UPPER(left(ref_type,3))
				else 
				IsNull(edicode,UPPER(left(ref_type,3)))
			  End,	
	ref_number,
	ref_sequence
   FROM referencenumber ref, process_requirements pr, labelfile lbl
   WHERE ref.ref_type = lbl.abbr
     AND pr.prq_reftype = '^ALL^'
     AND pr.prq_reftable = '^all^'
     AND lbl.labeldefinition = 'ReferenceNumbers'
     AND pr.prq_214export = 'Y'
     AND ref.ref_table = @table
     AND pr.prq_billto = @company_id
     AND ref.ref_tablekey = @key
-- PTS 16223 -- BL (end)

--AROSS PTS 28633 Update the reference codes with data from edireferencenumber table if it exists
  IF (SELECT COUNT(*) from edireferencenumber where ref_code in (Select distinct(ref_type) from #reftemp)
	and cmp_id = @company_id) > 0
	 BEGIN
		UPDATE #reftemp
		SET	edicode = edi_ref_code
		FROM	edireferencenumber, #reftemp
		WHERE	#reftemp.ref_type = edireferencenumber.ref_code
				AND edireferencenumber.cmp_id = @company_id
	 END		
-- create #4 misc records 
if @customsort is null or @customsort = ''

	INSERT edi_214 (data_col,trp_id, doc_id)
	SELECT datacol = '4' +
		'39' +
		'REF' +
		edicode + replicate(' ',3-datalength(edicode)) +
		ref_number + replicate (' ',76-datalength(ref_number)),
		trp_id = @trpid, doc_id = @docid
	FROM #reftemp
	order by ref_sequence

else  
begin --19520 ntk custom sort.
	while @nextpos > 0
	begin
		select @nextpos = charindex(',',@customsort,@startpos)
	
		if @nextpos > 0
		begin
			select @nextreftype = substring(@customsort,@startpos,@nextpos - @startpos), @startpos = @nextpos + 1
		end
		else
		begin
			select @nextreftype = substring(@customsort,@startpos,len(@customsort) + 1 - @startpos), @startpos = @nextpos + 1
		end

		INSERT edi_214 (data_col,trp_id, doc_id)
		SELECT datacol = '4' +
			'39' +
			'REF' +
			edicode + replicate(' ',3-datalength(edicode)) +
			ref_number + replicate (' ',76-datalength(ref_number)),
			trp_id = @trpid, doc_id = @docid
		FROM #reftemp
		where ref_type = @nextreftype
		order by ref_sequence
		
		delete #reftemp where ref_type = @nextreftype
	end
	INSERT edi_214 (data_col,trp_id, doc_id)
	SELECT datacol = '4' +
		'39' +
		'REF' +
		edicode + replicate(' ',3-datalength(edicode)) +
		ref_number + replicate (' ',76-datalength(ref_number)),
		trp_id = @trpid, doc_id = @docid
	FROM #reftemp
	order by ref_sequence

end	
GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_4_39_sp] TO [public]
GO
