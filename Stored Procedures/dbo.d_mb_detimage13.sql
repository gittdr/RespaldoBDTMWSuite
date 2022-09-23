SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
/*
  Return images of the masterbill data for the arguments passed.  Masterbill format 13
  does not use the revtype values or ship date range or del date range.  THey are passed
  in case some future masterbill image format may require them - can use the same call.

  Pagination is handled by putting line numbers on the rows and recycling the line
  numbers at the page limit.  Here the first line is 16 (last line of hdr is
  15) goes up to 62 then goes back to 16.  The app forces out footer followed
  by header records when the line number cycles back to the lowest.

  CHANGE HISTORY

  CREATED dpete pts9841 2/13/01
  PTS 10198 add back delivery lines to get stop city names; change where clause to
	more closely match printed mb13
  PTS 10217 3/13/01 do not print the billing qty if the charge is zero
 * 11/30/2007.01 ? PTS40463 - JGUO ? convert old style outer join syntax to ansi outer join syntax.

*/

CREATE PROCEDURE [dbo].[d_mb_detimage13] 
	@billto varchar(8),
	@mbnumber int,
	@revtype1 varchar(6),
	@revtype2 varchar(6),
	@revtype3 varchar(6),
	@revtype4 varchar(6),
	@shipstart datetime,
	@shipend datetime,
	@delstart datetime,
	@delend datetime,
	@shipper varchar(8),
	@consignee varchar(8) 
	
	
AS

--PTS 35444
DECLARE @procname varchar(128)
SELECT @procname = gi_string2 FROM generalinfo WHERE gi_name = 'SpoolFileImageName'
IF RTRIM(ISNULL(@procname,'')) > ''
BEGIN
	SELECT @procname = 'd_mb_detimage_' + RTRIM(@procname)
	EXEC @procname @billto, @mbnumber, @revtype1, @revtype2, @revtype3, @revtype4, @shipstart, @shipend, @delstart, @delend, @shipper, @consignee
	RETURN
END

/* this procedure returns one page of an masterbill (detail section ) arguments include the 
   invoice number and the detail item of the invoice to start with.  if there is more data to 
   print it returns *nn where nn is the next line number

    MODIFICATION LOG

created 2/5/01 DPETE for Cowan input to Pegasus


*/

  DECLARE @nextline smallint,
	@totalamt money,
	@totaldue char(12),
	@invoicenumber char(8),
 	@deliverydate  char(8),
 	@consigneename char(18),
 	@description char(18),
 	@refnumber char(10),
 	@billquantity char(8),
 	@rate char(8),
 	@rateunit char(5),
 	@charge char(13),
 	@stpcity char(15),
 	@cmp_id varchar(8),
 	@chargemoney money,
	@ivhhdrnumber int,
	@nextsequence char(14),
	@ord_number char(12) -- RE - 10/04/01 - PTS 11541



 CREATE TABLE #mbtemp (
 ivh_hdrnumber int,
 invoicenumber char(8),
 deliverydate  char(8),
 consigneename char(18),
 description char(18),
 refnumber char(10),
 billquantity char(8),
 rate char(8),
 rateunit char(5),
 charge char(13),
 stpcity char(15),
 cmp_id varchar(8),
 chargemoney money,
 sequencer char(14),
 ord_number char(12)


)
 

 INSERT INTO #mbtemp 
 SELECT 
ih.ivh_hdrnumber,
 invoicenumber = SUBSTRING(CONVERT(char(8),ivh_invoicenumber),1,8),
 deliverydate = CONVERT(char(8),ivh_deliverydate,1),
 consigneename = CONVERT(char(18),SUBSTRING(cc.cmp_name,1,18)),	
 description = 
	CASE ivd_type
		WHEN 'SUB' THEN 'Linehaul Charge   '
		WHEN 'DEL' THEN CONVERT(char(18),SUBSTRING(ISNULL(ivd_description,' '),1,18))
		ELSE CONVERT(char(18),SUBSTRING(ISNULL(cht_description,' '),1,18))
	END,
 refnumber = CONVERT(char(10),SUBSTRING(ISNULL(ivh_ref_number,''),1,10)),
 billquantity = 
	  CASE 
	  WHEN ivd_charge <> 0  then
	    CASE 
	    WHEN CONVERT(decimal(12,4),ISNULL(ivd_quantity,0) - convert(int,ISNULL(ivd_quantity,0)))  = 0
	  	 THEN ISNULL(REPLICATE (' ',8 - LEN(CONVERT(varchar(8),CAST(ivd_quantity AS dec(8,0))))) +
		CONVERT(varchar(8),CAST(ivd_quantity AS dec(8,0))),'        ')
	    WHEN CONVERT(decimal(12,4),(ISNULL(ivd_quantity,0)*10) - convert(int,(ISNULL(ivd_quantity,0)*10)))  = 0
		THEN ISNULL(REPLICATE (' ',8 - LEN(CONVERT(varchar(8),CAST(ivd_quantity AS dec(8,1))))) +
		CONVERT(varchar(8),CAST(ivd_quantity AS dec(8,1))),'        ')
	    WHEN CONVERT(decimal(12,4),(ISNULL(ivd_quantity,0)*100) - convert(int,(ISNULL(ivd_quantity,0)*100)))  = 0
		THEN ISNULL(REPLICATE (' ',8 - LEN(CONVERT(varchar(8),CAST(ivd_quantity AS dec(8,2))))) +
		CONVERT(varchar(8),CAST(ivd_quantity AS dec(8,2))),'        ')
	    WHEN CONVERT(decimal(12,4),(ISNULL(ivd_quantity,0)*1000) - convert(int,(ISNULL(ivd_quantity,0)*1000)))  = 0
		THEN ISNULL(REPLICATE (' ',8 - LEN(CONVERT(varchar(8),CAST(ivd_quantity AS dec(8,3))))) +
		CONVERT(varchar(8),CAST(ivd_quantity AS dec(8,3))),'        ')
	    WHEN CONVERT(decimal(12,4),(ISNULL(ivd_quantity,0)*10000) - convert(int,(ISNULL(ivd_quantity,0)*10000)))  = 0
		THEN ISNULL(REPLICATE (' ',8 - LEN(CONVERT(varchar(8),CAST(ivd_quantity AS dec(8,4))))) +
		CONVERT(varchar(8),CAST(ivd_quantity AS dec(8,4))),'        ')
	    END
	  ELSE REPLICATE(' ',8)
	  END,
 rate = 
	CASE 
	  WHEN ivd_charge <> 0  and CONVERT(decimal(12,4),(ISNULL(ivd_rate,0)*100) - convert(int,(ISNULL(ivd_rate,0)*100)))  = 0
		THEN ISNULL(REPLICATE (' ',8 - LEN(CONVERT(varchar(8),CAST(ivd_rate AS dec(8,2))))) +
		CONVERT(varchar(8),CAST(ivd_rate AS dec(8,2))),'        ')
	  WHEN ivd_charge <> 0 
		THEN ISNULL(REPLICATE (' ',8 - LEN(CONVERT(varchar(8),CAST(ivd_rate AS dec(8,4))))) +
		CONVERT(varchar(8),CAST(ivd_rate AS dec(8,4))),'        ')
	  ELSE REPLICATE (' ',8)
	END,
 rateunit = 
	CASE
	  WHEN ivd_charge <> 0 THEN CONVERT(char(5),ch.cht_rateunit)
	  ELSE REPLICATE (' ',5)
	END,
 charge = 
	CASE
		WHEN ivd_charge <> 0 then CONVERT(char(13),ivd_charge)
		ELSE REPLICATE (' ',13)
	END,
 stpcity = ' ',
 cmp_id = ISNULL(st.cmp_ID,''),
 chargemoney = ISNULL(ivd_charge,0),
 sequencer = convert(char(10),ivh_invoicenumber)+REPLICATE(' ',4 - LEN(convert(varchar(4),ivd_sequence)))+convert(varchar(4),ivd_sequence),
 ih.ord_number -- RE - 10/04/01 - PTS 11541
 FROM invoiceheader ih, chargetype ch, 
	  stops st right outer join invoicedetail id on st.stp_number = id.stp_number, 
	  company cc
 WHERE ivh_billto = @billto
 AND   ivh_mbstatus = 'RTP'
 AND   id.ivh_hdrnumber = ih.ivh_hdrnumber 
 AND   ch.cht_itemcode = id.cht_itemcode
 --AND   st.stp_number =* id.stp_number
 AND   cc.cmp_id = ivh_consignee
 AND (@shipper in (ih.ivh_shipper,'UNKNOWN'))
 AND (@consignee in (ih.ivh_consignee,'UNKNOWN'))
 AND ivh_shipdate between @shipstart and @shipend
 AND @revtype1 in (ih.ivh_revtype1,'UNK')
 AND @revtype2 in (ih.ivh_revtype2,'UNK')
 ORDER BY ivh_invoicenumber,ivd_sequence


 UPDATE #mbtemp
 SET stpcity = 
	CASE 
	WHEN CHARINDEX('/',cty_nmstct,0)> 0 THEN CONVERT(char(15),SUBSTRING(SUBSTRING(cty_nmstct,1,CHARINDEX('/',cty_nmstct,0)- 1),1,15))
	WHEN LEN(cty_nmstct) > 0 THEN CONVERT(char(15),SUBSTRING(ISNULL(cty_nmstct,' '),1,15))
	ELSE REPLICATE (' ',30)
	END
 FROM company
 WHERE LEN(RTRIM(#mbtemp.cmp_id))  > 0
 AND #mbtemp.cmp_id <> 'UNKNOWN'
 AND company.cmp_id = #mbtemp.cmp_id
 




 
 CREATE TABLE #image (
   image varchar(250), sequencecontrol varchar(25)
)
  SELECT @nextline = 16
  SELECT @nextsequence = REPLICATE(' ',3)
  SELECT @totalamt = 0
 
 WHILE (SELECT COUNT(*) FROM #mbtemp WHERE sequencer > @nextsequence) > 0
 BEGIN
  SELECT @nextsequence = MIN(sequencer) FROM #mbtemp WHERE sequencer > @nextsequence
 
   SELECT @ivhhdrnumber = ivh_hdrnumber,
	@invoicenumber = invoicenumber ,
 	@deliverydate = deliverydate ,
 	@consigneename = consigneename ,
	 @description = description ,
 	@refnumber = refnumber ,
 	@billquantity = billquantity ,
 	@rate = rate ,
	@rateunit = rateunit ,
 	@charge= charge ,
 	@stpcity = stpcity ,
	@cmp_id = cmp_id,
	@chargemoney = chargemoney,
	@ord_number = ord_number -- RE - 10/04/01 - PTS 11541
  FROM #mbtemp WHERE sequencer = @nextsequence

  INSERT INTO #image
    SELECT 
	'0' + REPLICATE('0',2 - LEN(CONVERT(varchar(2),@nextline )))+CONVERT(varchar(2),@nextline ) +
	@invoicenumber + REPLICATE (' ',1) +
	@deliverydate  + REPLICATE (' ',1) +
	@consigneename + REPLICATE (' ',1) +
	@description  +  REPLICATE (' ',1) +
	@refnumber +
	@billquantity +
	@rate + REPLICATE (' ',1) +
	@rateunit +
	@charge + REPLICATE (' ',1) +
	@stpcity + REPLICATE (' ',30)+
	CONVERT(varchar(12),@ivhhdrnumber) + REPLICATE(' ',12 - LEN(CONVERT(varchar(12),@ivhhdrnumber))) +
	@ord_number + REPLICATE(' ', 12 - LEN(@ord_number)),
	@nextsequence

 

   SELECT @totalamt = @totalamt + @chargemoney
   

   If @nextline < 62 SELECT @nextline = @nextline + 1
   ELSE SELECT  @nextline = 16
   

 END
  

  INSERT INTO #image
    SELECT
     '0' + REPLICATE('0',2 - LEN(CONVERT(varchar(2),@nextline )))+CONVERT(varchar(2),@nextline ) +
     REPLICATE (' ', 76) + 'Grand Total:' +
     REPLICATE(' ',13 - LEN(CONVERT(char(13),@totalamt))) + CONVERT(char(13),@totalamt) + REPLICATE (' ',46),
	'zzzzzzzzzzzz'
     
  SELECT image from #image 
  ORDER BY sequencecontrol


GO
GRANT EXECUTE ON  [dbo].[d_mb_detimage13] TO [public]
GO
