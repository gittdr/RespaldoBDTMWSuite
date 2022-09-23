SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[edi_210_record_id_5_39_sp]
	@invoice_number varchar(12),
	@table varchar(20),
	@key integer,
	@trpid varchar(20),
	@docid varchar(30)
 as
 
 /**
 * 
 * NAME:
 * dbo.edi_210_record_id_5_39_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure creates the miscellaneous "5" records for the EDI 210 document.  
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @invoice_number, varchar(12), input, null;
 *       This parameter indicates the invoice number for which the records are being created.
 * 002 - @table, varchar(20), input, null;
 *       This parameter indicates the type pof reference number for which the record is being created.
 * 003 - @trpid, varchar(20), input, null;
 *       This parameter indicates the trading partner for which the EDI 210 is being
 *       created.
 * 004 - @docid, varchar(30), input, null;
 *		 This parameter indicates the document id for the individual edi 210 transaction.
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * CalledBy001 ? edi_210_all_39_sp
 * CalledBy002 ? edi_210_record_id_4_39_sp

 * 
 * REVISION HISTORY:
 * 03/1/2005.01 ? PTSnnnnn - AuthorName ? Revision Description
 * dpete pts 7276 pull refs for level needed
 * DPETE PTS 14524 noticed  some ref recs not produced because edi codes exceeded 3 positions
 * DPETE PTS21382 handle refs for invoiceheader on misc invoices
 * DPETE 21382 continued  EDI Dept want dd of 'invoice header' added to process requirements instead of using orderhesader entries
 * 06/25/2005.05 - PTS28633 -  A. Rossman - Added ability to use reference number code specified at the TP level.
 * 10/18/2005.06 - PTS30167 -  A. Rossman - Allow nulls on reference number temp table.
 * 11/12/2007.01 ? PTS40187 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/



declare @billto 	varchar(8)
declare @emptystring varchar(79),@systemowner varchar(40),@billdate datetime
declare @formattedbilldate varchar(8),@formattedtoday varchar(8),@alias varchar(3)
declare @status char, @yyyy varchar(4),@mm varchar(3),@dd varchar(2)
declare @statustext varchar(4), @shipticket varchar(30), @ordhdrnumber int
declare @totalgallons varchar(9), @ediqualifier char(3)

--19520 ntk Custom sorting of references.
declare @customsort varchar(60), @startpos int, @nextpos int, @nextreftype varchar(6)
select @customsort = gi_String1, @startpos = 1, @nextpos = 1 from generalinfo where gi_name = 'EDIRefCustomSort'

  SELECT @emptystring = ''

	SELECT @billdate = ivh_billdate,
		@billto  = ivh_billto,
		@ordhdrnumber = ord_hdrnumber
	FROM    invoiceheader
	WHERE 	ivh_invoicenumber = @invoice_number
 -- ID the system owner 
  	SELECT @systemowner = upper(gi_string1)
	FROM generalinfo
	WHERE gi_name = 'SystemOwner'


if @systemowner = 'FLORIDAROCK'
   BEGIN
   If @table = 'orderheader'
     BEGIN
	

	SELECT	@alias = trp_alias,
		@status = trp_status
	FROM	edi_trading_partner
	WHERE	cmp_id = @billto

	SELECT @shipticket = ref_number
	FROM   referencenumber
        WHERE  ref_table = 'ORDERHEADER' 
          AND  ref_tablekey = @ordhdrnumber
	  AND  ref_type = 'SHIPTK'

	--**** this is an interim fix for FR going live soon may not work for
	--**** other FR businesses
	SELECT  @totalgallons = convert(varchar(9),SUM(ivd_quantity))
	FROM   invoicedetail 
	WHERE   ord_hdrnumber = @ordhdrnumber
	AND	 ivd_unit = 'GAL'

	SELECT @ediqualifier = convert(char(3),edicode)
	FROM   labelfile

	WHERE	 labeldefinition = 'VolumeUnits'
	AND	 abbr = 'GAL'

	-- condition the billdate
	
	select @yyyy=convert( varchar(4),datepart(yy,@billdate)),
		@mm=convert( varchar(2),datepart(mm,@billdate)),
		@dd=convert( varchar(2),datepart(dd,@billdate))

	SELECT  @formattedbilldate = replicate('0',4-datalength(@yyyy)) + @yyyy +
		replicate('0',2-datalength(@mm)) + @mm +
		replicate('0',2-datalength(@dd)) + @dd

	-- condition current date
	SELECT @yyyy=convert( varchar(4),datepart(yy,getdate())),
		@mm=convert( varchar(2),datepart(mm,getdate())),
		@dd=convert( varchar(2),datepart(dd,getdate()))

	SELECT @formattedtoday = replicate('0',4-datalength(@yyyy)) + @yyyy +
		replicate('0',2-datalength(@mm)) + @mm +
		replicate('0',2-datalength(@dd)) + @dd

	-- convert the T/P status code to the text
	SELECT @statustext = 'TEST' where @status = 'T'
	SELECT @statustext = 'PROD' where @status = 'P'

	-- add a record for the as of bill date
	INSERT edi_210
		SELECT 
		data_col = '5' +				-- Record ID
		'39' +						-- Record Version
		'BDT' +	-- misc data type
		@formattedbilldate +	replicate(' ',79-datalength(@formattedbilldate)),	-- misc data
		doc_id = @docid,
		trp_id=@trpid
	-- add a record for today's date
	
	INSERT edi_210
		SELECT 
		data_col = '5' +				-- Record ID

		'39' +						-- Record Version
		'CDT' +	-- misc data type
		@formattedtoday +	replicate(' ',79-datalength(@formattedtoday)),	-- misc data
		doc_id = @docid,
		trp_id=@trpid
	
	-- add a record for the alias
	INSERT edi_210
		SELECT 
		data_col = '5' +				-- Record ID
		'39' +						-- Record Version
		'ALS' +	-- misc data type
		@alias +	replicate(' ',79-datalength(@alias)),	-- misc data
		doc_id = @docid,
		trp_id=@trpid
	
	-- add a record for the alias
	INSERT edi_210
		SELECT 
		data_col = '5' +				-- Record ID
		'39' +						-- Record Version
		'SHP' +	-- misc data type
		@shipticket +	replicate(' ',79-datalength(@alias)),	-- misc data
		doc_id = @docid,
		trp_id=@trpid
	-- add a record for the test/prod status
	INSERT edi_210
		SELECT 
		data_col = '5' +				-- Record ID
		'39' +						-- Record Version
		'STS' +	-- misc data type
		@statustext +	replicate(' ',79-datalength(@statustext)),	-- misc data
		doc_id = @docid,
		trp_id=@trpid
	
	-- add a record for the total volume
	INSERT edi_210
		SELECT 
		data_col = '5' +				-- Record ID
		'39' +						-- Record Version
		'VOL' +	-- misc data type
		@ediqualifier    +     replicate(' ',3-datalength(@ediqualifier)) +
		@totalgallons +	replicate(' ',76-datalength(@statustext)),	-- misc data
		doc_id = @docid,
		trp_id=@trpid


     END
 
   END

	-- now create regular ref numbers
	

Create Table #prq (
prq_reftype varchar(6) null,
prq_reftable varchar(50) null
)

-- (2) if proces reqs has '^all^' tables plug the one passed to ensure match later (do this here to avoid
--     picking up refs for other types of tables with the same 'key'
Insert into #prq
Select prq_reftype,
  prq_reftable = Case  
--  When Upper(@table + prq_reftable) = 'INVOICEHEADERORDERHEADER' Then 'invoiceheader' 
  When Upper(prq_reftable) = '^ALL^' Then @table
  Else prq_reftable End
From process_requirements
Where
prq_billto =  @billto
and prq_210export = 'Y'

Delete from #prq
Where prq_reftable Not In (@table,'^ALL^')



  CREATE TABLE #reftemp (
	ref_type varchar(6) NULL,
	edicode varchar(3) NULL,
	ref_number varchar(50) NULL,
	ref_sequence int NULL)
      
/*
-- PTS 16223 -- BL (start)
--   (allow for 'All' option for ref_type and ref_table on EDI_214_profile table)
--   INSERT #reftemp
--    SELECT ref_type,
-- 	Substring(UPPER(ISNULL(edicode,'ZZ ')),1,3) edicode,
-- 	Substring(ref_number,1,50)
--    FROM referencenumber r,labelfile l
--    WHERE r.ref_table = @table
--    AND   r.ref_tablekey = @key
--    AND   r.ref_type in (SELECT prq_reftype
-- 		FROM process_requirements
-- 		WHERE prq_billto = @billto
-- 		AND PRQ_reftable = @table
-- 		AND prq_210export = 'Y')
--    AND l.labeldefinition = 'ReferenceNumbers'
--    AND l.abbr =* r.ref_type
  INSERT #reftemp
   SELECT ref_type,
	Substring(UPPER(ISNULL(edicode,'ZZ ')),1,3) edicode,
	Substring(ref_number,1,50),
	ref_sequence
   FROM referencenumber ref, process_requirements pr, labelfile lbl
   WHERE ref.ref_type = pr.prq_reftype
     AND ref.ref_table = pr.prq_reftable
     AND ref.ref_type = lbl.abbr
     AND lbl.labeldefinition = 'ReferenceNumbers'
     AND pr.prq_210export = 'Y'
     AND pr.prq_reftable = @table
     AND pr.prq_billto = @billto
     AND ref.ref_tablekey = @key
  UNION
   SELECT ref_type,
	Substring(UPPER(ISNULL(edicode,'ZZ ')),1,3) edicode,
	Substring(ref_number,1,50),
	ref_sequence
   FROM referencenumber ref, process_requirements pr, labelfile lbl
   WHERE ref.ref_type = pr.prq_reftype
     AND ref.ref_type = lbl.abbr
     AND pr.prq_reftable = '^all^'
     AND lbl.labeldefinition = 'ReferenceNumbers'
     AND pr.prq_210export = 'Y'
     AND ref.ref_table = @table
     AND pr.prq_billto = @billto
     AND ref.ref_tablekey = @key
  UNION
   SELECT ref_type,
	Substring(UPPER(ISNULL(edicode,'ZZ ')),1,3) edicode,
	Substring(ref_number,1,50),
	ref_sequence
   FROM referencenumber ref, process_requirements pr, labelfile lbl
   WHERE ref.ref_table = pr.prq_reftable
     AND ref.ref_type = lbl.abbr
     AND pr.prq_reftype = '^ALL^'
     AND lbl.labeldefinition = 'ReferenceNumbers'
     AND pr.prq_210export = 'Y'
     AND pr.prq_reftable = @table
     AND pr.prq_billto = @billto
     AND ref.ref_tablekey = @key
  UNION
   SELECT ref_type,
	Substring(UPPER(ISNULL(edicode,'ZZ ')),1,3) edicode,
	Substring(ref_number,1,50),
	ref_sequence
   FROM referencenumber ref, process_requirements pr, labelfile lbl
   WHERE ref.ref_type = lbl.abbr
     AND pr.prq_reftype = '^ALL^'
     AND pr.prq_reftable = '^all^'
     AND lbl.labeldefinition = 'ReferenceNumbers'
     AND pr.prq_210export = 'Y'
     AND ref.ref_table = @table
     AND pr.prq_billto = @billto
     AND ref.ref_tablekey = @key
-- PTS 16223 -- BL (end)

*/
  
--insert references into temp table  
INSERT #reftemp  
   SELECT ref_type,  
    edicode =  Rtrim(isNull(edicode,LEFT(REF_TYPE,3))),
    ref_number,  
    ref_sequence  
   FROM referencenumber ref LEFT OUTER JOIN labelfile lbl ON ( ref.ref_type = lbl.abbr and lbl.labeldefinition = 'ReferenceNumbers' ),
		#prq pr  --pts40187 jguo outer join conversion
   WHERE ref.ref_type = Case Upper(pr.prq_reftype) When '^ALL^' Then ref.ref_type Else pr.prq_reftype End
  And ref_table =  prq_reftable   -- if prq_reftable was '^ALL^' it was changed to passed @table  in #prq above 
  AND ref.ref_tablekey = @key    
  
  --AROSS PTS 28633 Update the reference codes with data from edireferencenumber table if it exists
  IF (SELECT COUNT(*) from edireferencenumber where ref_code in (Select distinct(ref_type) from #reftemp)
	and cmp_id = @billto) > 0
	 BEGIN
		UPDATE #reftemp
		SET	edicode = edi_ref_code
		FROM	edireferencenumber, #reftemp
		WHERE	#reftemp.ref_type = edireferencenumber.ref_code
				AND edireferencenumber.cmp_id = @billto
	 END

 -- create #5 misc records 
if @customsort is null or @customsort = ''
    INSERT edi_210 (data_col,doc_id,trp_id)
     SELECT datacol = '5' +
	'39' +
	'REF' +
	edicode + replicate(' ',3-datalength(edicode)) +
	ref_number + replicate (' ',76-datalength(ref_number)),
	doc_id = @docid,
	trp_id = @trpid
     FROM #reftemp
	order by ref_sequence
else
begin
	while @nextpos > 0
	begin
		select @nextpos = charindex(',',@customsort,@startpos)
	
		if @nextpos > 0
		begin
			select @nextreftype = substring(@customsort,@startpos,@nextpos - @startpos), @startpos = @nextpos + 1
		end
		else
		begin
			select @nextreftype = substring(@customsort,@startpos,len(@customsort) +1 - @startpos), @startpos = @nextpos + 1
		end

	    INSERT edi_210 (data_col,doc_id,trp_id)
	     SELECT datacol = '5' +
		'39' +
		'REF' +
		edicode + replicate(' ',3-datalength(edicode)) +
		ref_number + replicate (' ',76-datalength(ref_number)),
		doc_id = @docid,
		trp_id = @trpid
	     FROM #reftemp
	     where ref_type = @nextreftype
		order by ref_sequence
		
		delete #reftemp where ref_type = @nextreftype
	end
    INSERT edi_210 (data_col,doc_id,trp_id)
     SELECT datacol = '5' +
	'39' +
	'REF' +
	edicode + replicate(' ',3-datalength(edicode)) +
	ref_number + replicate (' ',76-datalength(ref_number)),
	doc_id = @docid,
	trp_id = @trpid
     FROM #reftemp
	order by ref_sequence
end	

GO
GRANT EXECUTE ON  [dbo].[edi_210_record_id_5_39_sp] TO [public]
GO
