SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[d_gp_cash_receipt_mem_sp] (@p_billto varchar(15), @p_reftype1 varchar(8), @p_reftype2 varchar(8), 
                                                                                     @p_server varchar(128), @p_database varchar(128), @p_userid varchar(128), @p_password varchar(128), @p_checktotal money)
as

/*
Name:
dbo.d_gp_cash_receipt_sp

Type:
[StoredProcedure]

Description:
This procedure returns a set of open invoices for a billto  from Great plains and then adds in 
TMW reference numbers---This is used in the Cash reciept application

Returns:
none

Paramaters:
001 - @p_billto varchar(15), input null;
	this paramater indicates the Bill to for whom I am retrieving data.  PTS 68619   expanded to 15
002 - @p_reftype1 varchar(8),  input null;
	this paramter indicates the reference type to be used in the first refnumber field
	order# returns order number
	all other options return the ref type specified
003 - @p_reftype2 varchar(8),  input null;
	this paramter indicates the reference type to be used in the second refnumber field
004 - @p_server varchar(128),  input null;
	this paramater indicates the Great Plains server that I connect to retrieve the GP data.
005 - @p_database varchar(128),  input null;
	this paramater indicates the Great Plains Database that I connect to retrieve the GP data.
006 - @p_userid varchar(128),  input null;
	this paramater indicates the user ID that I use to connect to the GP database.
007 - @p_password varchar(128),  input null;
	this paramater indicates the password that I use to connect to the GP database.
008 -  @p_checktotal money,  input null;
	this paramater indicates the total amount of the check that is being paid.

References:
 Calls001    ? NONE
 CalledBy001 ? d_gp_cash_reciept_mem (datawindow)

NOTE:  

Revision History
08/04/15.01 Ken Mader  - Creation

*/


IF LEN(@p_billto) < 1 OR @p_billto IS NULL OR @p_billto = 'UNKNOWN'
     RETURN

DECLARE @v_connection	varchar(128), 
        @v_schema	varchar(128),
        @GI_LinkedServer varchar(128),--.02 
        @GI_LinkedServerDatabase varchar(128),--.02
        @Gi_linkedserveron int--.02


--.02  KPM 9/5/12

IF  EXISTS (SELECT gi_name
                 FROM dbo.generalinfo
                WHERE gi_name = 'GPCustomLinkedServer' and gi_string1 is not null )

begin

	select @Gi_linkedserveron = isnull (gi_integer1, 0), 
	@GI_LinkedServer = ISNULL(gi_string1, '') , 
	@GI_LinkedServerDatabase = ISNULL(gi_string2, '')
	from generalinfo where gi_name = 'GPCustomLinkedServer' 

	if @Gi_linkedserveron > 0 
	begin

	set @v_connection = @GI_LinkedServer + '.' + @GI_LinkedServerDatabase + '.' + 'dbo.'
	set @p_server =''
	end
	

end
--.02  KPM 9/5/12

else
begin       
IF LEN(@p_server) > 0 AND LOWER(@@servername) <> LOWER(@p_server)
     SET @v_connection = @p_server + '.'
ELSE
BEGIN
     SET @p_server = ''
     SET @v_connection = ''
END

IF LEN(@p_database) > 0 
BEGIN
     SET @v_connection = @v_connection + @p_database + '.'
     SET @v_schema =  @p_database + '.'
END

SET @v_connection = @v_connection + 'dbo.'
SET @v_schema = @v_schema + 'dbo.'
end 


create table #temp
           ([file]                 	varchar(256)	not null	default ('NO'), 
            [date]              	varchar(20)	null, 
            [batch]            	varchar(10)	null, 
            [checkamount]	money     	null,
            [debit]             	char(1)     	not null	default('D'),                                        --5
            [docdate]      	varchar(20)	null, 
            [account]       	varchar(10)	null, 
            [multi]              	int               	null,
            [currency]      	varchar(10)	null, 
            [curidx]           	int               	null,                                                            --10
            [check]           	varchar(25)	not null	default('NO' ), 
            [checkbook] 	varchar(50)	null, 
            [payment]      	varchar(15)	null, 
            [totalunapplied]	money     	null, 
            [invoice]         	varchar(17)	null,                                                                    --15
            [invamount_1]	money     	null, 
            [sequence]   	int               	null, 
            [type]              	int               	null, 
            [writeofftype] 	int               	null, 
            [customerid] 	varchar(15)	null, --PTS 68619   expanded to 15                                           --20 
            [maxwriteoff] 	money     	not null	default(0), 
            [curtrxamt]     	money      	not null, 
            [writeoffamount]	money     	not null	default(0), 
            [difference]   	money     	not null	default(0), 
            [gotfocus]      	int               	not null	default(0),                                          --25
            [nationalaccount]	 varchar(15)	null,--PTS 68619   expanded to 15 
            [paymentamt]	money     	not null	default(0), 
            [refnum]          	varchar(30)	null, --pts 33343 referencenumber field was expanded from 25 to 30
            [customershortname]	varchar(15)	null, --PTS 68619   expanded to 15
            [refnum2]       	varchar(30)	null, --pts 33343 referencenumber field was expanded from 25 to 30       --30
            [apply]            	char(1)       	NULL, 
            [check_tot]    	money     	null          , 
            [manual]        	char(1)     	not null	default('N'))

declare @v_SQL nvarchar(max) 

SET ANSI_NULLS  ON
SET ANSI_WARNINGS ON

--print @v_connection

IF LEN(@p_server) > 0 
     BEGIN
     SELECT @v_SQL = N'INSERT INTO #temp (customerid, invoice, curtrxamt, writeofftype, maxwriteoff, nationalaccount, invamount_1, paymentamt) '
       SELECT @v_SQL = @v_SQL + N'SELECT openinv.CUSTNMBR, openinv.DOCNUMBR, openinv.CURTRXAM, '  
        SELECT @v_SQL = @v_SQL + N'customer.MXWOFTYP, customer.MXWROFAM, customer.CPRCSTNM, openinv.CURTRXAM, openinv.CURTRXAM '  
        SELECT @v_SQL = @v_SQL + N'FROM  OPENROWSET(''SQLOLEDB'','''+ @p_server + ''';''' + @p_userid + ''';''' + @p_password + ''',' + @v_schema + 'RM20101) as openinv, '  
        SELECT @v_SQL = @v_SQL + N'OPENROWSET(''SQLOLEDB'','''+ @p_server + ''';''' + @p_userid + ''';''' + @p_password + ''',' + @v_schema + 'RM00101) as customer '  
        SELECT @v_SQL = @v_SQL + N'WHERE (openinv.CUSTNMBR = ''' + @p_billto + ''' OR '  
        SELECT @v_SQL = @v_SQL + N'openinv.CUSTNMBR IN (SELECT nationalcustomer. CUSTNMBR '  
        SELECT @v_SQL = @v_SQL + N'FROM OPENROWSET(''SQLOLEDB'','''+ @p_server + ''';''' + @p_userid + ''';''' + @p_password + ''',' + @v_schema + 'RM00101) as nationalcustomer ' 
        SELECT @v_SQL = @v_SQL + N' WHERE nationalcustomer.CPRCSTNM = ''' + @p_billto + ''')) '   
        SELECT @v_SQL = @v_SQL + N'AND openinv.CUSTNMBR = customer.CUSTNMBR AND '  
        SELECT @v_SQL = @v_SQL + N'openinv.RMDTYPAL in ( 1, 3, 5) AND openinv.CURTRXAM > 0' 
END

ELSE
BEGIN
     SELECT @v_SQL = 'INSERT INTO #temp (customerid, invoice, curtrxamt, writeofftype, maxwriteoff, nationalaccount, invamount_1, paymentamt) '   
        SELECT @v_SQL = @v_SQL + N' SELECT openinv.CUSTNMBR, openinv.DOCNUMBR, openinv.CURTRXAM, '  
        SELECT @v_SQL = @v_SQL + N'customer.MXWOFTYP, customer.MXWROFAM, customer.CPRCSTNM, openinv.CURTRXAM, openinv.CURTRXAM '  
        SELECT @v_SQL = @v_SQL + N'FROM ' + @v_connection + 'RM20101 as openinv, ' + @v_connection + 'RM00101 as customer '  
        SELECT @v_SQL = @v_SQL + N'WHERE (openinv.CUSTNMBR = ''' + @p_billto + ''' OR '  
        SELECT @v_SQL = @v_SQL + N'openinv.CUSTNMBR IN (SELECT  CUSTNMBR FROM ' + @v_connection + 'RM00101 '
       SELECT @v_SQL = @v_SQL + N'WHERE CPRCSTNM = ''' + @p_billto + ''')) '  
        SELECT @v_SQL = @v_SQL + N'AND openinv.CUSTNMBR = customer.CUSTNMBR AND ' 
        SELECT @v_SQL = @v_SQL + N'RMDTYPAL in ( 1, 3, 5) AND CURTRXAM > 0' 
END

EXEC sp_executesql @v_sql



update #temp
set check_tot =  @p_checktotal

IF LOWER(@p_reftype1) = 'order#'
    UPDATE #temp 
             SET refnum = (SELECT MAX(invoiceheader.ord_hdrnumber) 
                                              FROM invoiceheader 
                                          WHERE invoiceheader.ivh_invoicenumber = #temp.invoice) 
ELSE
     UPDATE #temp 
               SET refnum = ref_number 
           FROM invoiceheader, orderheader, referencenumber 
      WHERE invoiceheader.ivh_invoicenumber = #temp.invoice 
             AND orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber 
             AND referencenumber.ref_tablekey = orderheader.ord_hdrnumber 
             AND LOWER(referencenumber.ref_type) = LOWER(RTRIM(@p_reftype1)) 
             AND referencenumber.ref_table = 'orderheader' 
             AND referencenumber.ref_sequence = (SELECT MIN(r2.ref_sequence) FROM referencenumber AS r2 
                                                                                            WHERE r2.ref_tablekey = orderheader.ord_hdrnumber 
                                                                                                   AND LOWER(r2.ref_type) = LOWER(RTRIM(@p_reftype1)) 
                                                                                                   AND r2.ref_table = 'orderheader' )

     UPDATE #temp 
               SET refnum2 = referencenumber.ref_number 
           FROM invoiceheader, orderheader, referencenumber 
      WHERE invoiceheader.ivh_invoicenumber = #temp.invoice 
             AND orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber 
             AND referencenumber.ref_tablekey = orderheader.ord_hdrnumber 
             AND LOWER(referencenumber.ref_type) = LOWER(RTRIM(@p_reftype2)) 
             AND referencenumber.ref_table = 'orderheader' 
             AND referencenumber.ref_sequence = (SELECT MIN(r2.ref_sequence) FROM referencenumber AS r2 
                                                                                            WHERE r2.ref_tablekey = orderheader.ord_hdrnumber 
                                                                                                   AND LOWER(r2.ref_type) = LOWER(RTRIM(@p_reftype2)) 
                                                                                                   AND r2.ref_table = 'orderheader' )

SELECT [file], [date], [batch], [checkamount], [debit], [docdate], 
                  [account], [multi], [currency], [curidx], [check], [checkbook], 
                  [payment], [totalunapplied], [invoice], [invamount_1], [sequence], 
                  [type], [writeofftype], [customerid], [maxwriteoff], [curtrxamt], 
                  [writeoffamount], [difference], [gotfocus], [nationalaccount], 
                  [paymentamt], [refnum], [customershortname],  [refnum2], 
                  [apply], [check_tot], [manual]
    FROM #temp
order by [customerid], [invoice]

drop table #temp
GO
GRANT EXECUTE ON  [dbo].[d_gp_cash_receipt_mem_sp] TO [public]
GO
