SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[PaperworkCountForOrder_sp] (	@OrdHdrNumber	int,
										@BillTo			varchar(8),
										@RequiredCnt	int OUTPUT,
										@ReceivedCnt	int OUTPUT)
										
AS
	--PTS 22338 Additional paperwork support for chargetypes per billto
    --pts 35950 IF PaperWorkCheckLevel= Leg do not countpaperwork records where 
    --     the lgh_number is no longer valid on the trip.  Finding the correct required doc count
    --      for this option is back in w_inv_edit wf_resetpaperworkcount with in line SQL
	--PTS 36869 EMK Added invoice required field to required paperwork queries

	DECLARE @PaperworkMode	char(1)
   
				
	SELECT	@PaperworkMode = gi_string1
	FROM	generalinfo
	WHERE	(gi_name = 'PaperWorkMode')

	If @PaperworkMode = 'A' BEGIN
		SELECT	@RequiredCnt = count(*) 
		FROM	labelfile
		WHERE	labeldefinition = 'PaperWork'
				and retired <> 'Y'

		SELECT	@ReceivedCnt = COUNT(*)
		FROM	paperwork
		WHERE	ord_hdrnumber = @OrdHdrNumber
				and pw_received = 'Y'
	END	
	ELSE BEGIN
		CREATE TABLE #RequiredPaperwork
			(
				Paperwork varchar(6) NOT NULL
			) 
			
		INSERT #RequiredPaperwork
			SELECT    bdt_doctype
			FROM        BillDoctypes
			WHERE    (cmp_id = @BillTo) AND (LEN(bdt_doctype) > 0)
				AND IsNull(bdt_inv_required,'Y') = 'Y'

		INSERT #RequiredPaperwork
			SELECT    cpw.cpw_paperwork
			FROM        chargetypepaperwork cpw INNER JOIN
			                     chargetype cht ON cpw.cht_number = cht.cht_number INNER JOIN
			                     invoicedetail ivd ON cht.cht_itemcode = ivd.cht_itemcode
			WHERE    (cht.cht_paperwork_requiretype = 'A') AND (ivd.ord_hdrnumber = @OrdHdrNumber)
				AND IsNull(cpw.cpw_inv_required,'Y')='Y' --PTS 36869

		INSERT #RequiredPaperwork
			SELECT    cpw.cpw_paperwork
			FROM        chargetypepaperwork cpw INNER JOIN
				         chargetype cht ON cpw.cht_number = cht.cht_number INNER JOIN
					     invoicedetail ivd ON cht.cht_itemcode = ivd.cht_itemcode INNER JOIN
						 invoiceheader ivh ON ivd.ivh_hdrnumber = ivh.ivh_hdrnumber
			WHERE    (cht.cht_paperwork_requiretype = 'O') AND (ivh.ord_hdrnumber = @OrdHdrNumber) AND (ivh.ivh_billto IN
                         (SELECT    cpwcmpinner.cmp_id
                           FROM        chargetypepaperworkcmp cpwcmpinner
                           WHERE    (cpwcmpinner.cht_number = cht.cht_number)))	
				AND IsNull(cpw.cpw_inv_required,'Y')='Y' --PTS 36869

		INSERT #RequiredPaperwork
			SELECT    cpw.cpw_paperwork
			FROM        chargetypepaperwork cpw INNER JOIN
				         chargetype cht ON cpw.cht_number = cht.cht_number INNER JOIN
					     invoicedetail ivd ON cht.cht_itemcode = ivd.cht_itemcode INNER JOIN
						 invoiceheader ivh ON ivd.ivh_hdrnumber = ivh.ivh_hdrnumber
			WHERE    (cht.cht_paperwork_requiretype = 'E') AND (ivh.ord_hdrnumber = @OrdHdrNumber) AND (ivh.ivh_billto NOT IN
                         (SELECT    cpwcmpinner.cmp_id
                           FROM        chargetypepaperworkcmp cpwcmpinner
                           WHERE    (cpwcmpinner.cht_number = cht.cht_number)))	
				AND IsNull(cpw.cpw_inv_required,'Y')='Y' --PTS 36869
	
		SELECT @RequiredCnt = count(DISTINCT Paperwork)
		FROM #RequiredPaperwork
	
		SELECT    @ReceivedCnt = COUNT(*) 
		FROM        paperwork 
		WHERE    (ord_hdrnumber = @OrdHdrNumber) AND (pw_received = 'Y') AND abbr IN
					 (SELECT Paperwork 
						FROM #RequiredPaperwork)
        and lgh_number in (select distinct lgh_number from stops where ord_hdrnumber = @OrdHdrNumber and ord_hdrnumber > 0)
		
	
	END			
	
GO
GRANT EXECUTE ON  [dbo].[PaperworkCountForOrder_sp] TO [public]
GO
