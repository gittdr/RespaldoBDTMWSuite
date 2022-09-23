SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_getcobnumber_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	@revtype1 varchar(6), @mbstatus varchar(6),
	@shipstart datetime,@shipend datetime,@billdate datetime, @shipper varchar(8), 
        @consignee varchar(8), @copy int, @ivh_invoicenumber varchar(12),
	@batch varchar(254), @batch_count int)
AS

DECLARE	@batch_id_1 	varchar(10),
	@i_batch	int,
	@batch_string	varchar(254),
	@count          int

select @batch_string = RTRIM(@batch)
select @i_batch = 0
select @count = 1

create table #batch (batch_id varchar(10) not null)
insert #batch (batch_id) values('XXX,')

WHILE @count <= @batch_count
BEGIN
	select @i_batch = charindex(',', @batch_string)
	If @i_batch > 0
	BEGIN
		SELECT @batch_id_1 = substring(@batch_string, 1, (@i_batch - 1))
		select @batch_string = substring(@batch_string, (@i_batch + 1), (254 - @i_batch))
		insert #batch (batch_id) values(@batch_id_1)
		select @count = @count + 1
	END
	If @count > 1 and @i_batch = 0
	BEGIN
		insert #batch (batch_id) values(@batch_string)
		select @count = @count + 1
	END
END

CREATE TABLE #cobtemp(
             ref_number varchar(30) null,
	     name       varchar(20) null,
	     shipdate   datetime    null)

if UPPER(@reprintflag) = 'REPRINT' 
BEGIN   
        Insert into #cobtemp
  	Select distinct ref.ref_number,
	       labelfile.name,
	       ivh_shipdate	
	FROM 	invoiceheader, 
		referencenumber ref,
		labelfile 
        WHERE	( invoiceheader.ivh_mbnumber = @mbnumber )
		AND (@shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))
		AND (@consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))
		AND invoiceheader.ord_hdrnumber = ref.ref_tablekey 
                AND ( ref.ref_type = labelfile.abbr ) 
       		AND ( labelfile.labeldefinition = 'ReferenceNumbers' )
		AND ref.ref_table = 'orderheader' 
		AND ref.ref_type = 'CPO'
		and ref.ref_sequence = (select min(ref_sequence) from referencenumber r1
                                        where r1.ref_table = 'orderheader' and r1.ref_type = 'CPO'and
                                              r1.ref_tablekey = invoiceheader.ord_hdrnumber)
		

  		
END

-- for master bills with 'RTP' status

IF UPPER(@reprintflag) <> 'REPRINT' 
BEGIN
        insert into #cobtemp
	Select distinct ref.ref_number,
	       labelfile.name,
		ivh_shipdate
        FROM 	invoiceheader, 
		referencenumber ref,
		labelfile,
		#batch
        WHERE invoiceheader.ivh_billto = @billto and
              invoiceheader.ivh_shipdate between @shipstart AND @shipend and 
              invoiceheader.ivh_mbstatus = 'RTP' and 
              @revtype1 in (invoiceheader.ivh_revtype1,'UNK') and 
              @shipper in (invoiceheader.ivh_shipper,'UNKNOWN') and
              @consignee IN (invoiceheader.ivh_consignee,'UNKNOWN') and
              @ivh_invoicenumber IN (invoiceheader.ivh_invoicenumber, 'Master') and
	      invoiceheader.ord_hdrnumber = ref.ref_tablekey and
	      ( ref.ref_type = labelfile.abbr ) and
       	      ( labelfile.labeldefinition = 'ReferenceNumbers' ) and
	       ref.ref_table = 'orderheader' and
	       ref.ref_type = 'CPO' and
	       ref.ref_sequence = (select min(ref_sequence) from referencenumber r1
                                        where r1.ref_table = 'orderheader' and r1.ref_type = 'CPO'and
                                              r1.ref_tablekey = invoiceheader.ord_hdrnumber)
		And   isnull(ivh_batch_id,0) = case when @batch_count > 0 then #batch.batch_id else isnull(ivh_batch_id,0) end
END

select top 3 ref_number,name, min(shipdate) from #cobtemp group by ref_number,name order by min(shipdate)
drop table #cobtemp
GO
GRANT EXECUTE ON  [dbo].[d_getcobnumber_sp] TO [public]
GO
