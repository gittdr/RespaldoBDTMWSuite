SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RptDeliveryReceipt]
 @MfhNumber int = null,
 @ord_hdrnumber int = null,
 @delivery_terminal varchar(8) = null,
 @delivery_date datetime = null
AS
BEGIN  
   
  CREATE TABLE #docs  
 (  
  id    INT,  
  Description  VARCHAR(20),  
  whosecopy varchar(50)  
 );  
  
 insert into #docs(id, Description, whosecopy) values (1, 'Customer Copy', 'Delivery Receipt');  
 insert into #docs(id, Description, whosecopy) values (2, 'Driver Copy', 'Consignee Copy');  
  
 CREATE TABLE #dr(  
   copy_id   INT,  
   copy_description  VARCHAR(20),  
   whosecopy varchar(50),  
   mfh_number  INT,  
   mov_number  INT,  
   tractor   VARCHAR(8),  
   driver1   VARCHAR(8),  
   trailer1   VARCHAR(13),  
   trailer2   VARCHAR(13),  
   stp_number  INT,  
   ord_hdrnumber  INT,  
   eventcode   VARCHAR(6),  
   ord_number  VARCHAR(12),  
   pro_number  VARCHAR(30),  
   origin   VARCHAR(8),  
   unit_id   VARCHAR(13),  
   unit_pos   VARCHAR(6) DEFAULT '',  
   stop_name   VARCHAR(30),  
   stop_city   VARCHAR(18),   
   stop_state  VARCHAR(6),  
   shipper_id        VARCHAR(8),  
   shipper_phone     VARCHAR(20),  
   shipper_name  VARCHAR(30),  
   shipper_city  VARCHAR(18),   
   shipper_address   VARCHAR(40), 
   shipper_address2   VARCHAR(40),   
   shipper_zipcode   VARCHAR(10),  
   shipper_state  VARCHAR(6),  
   consignee_name    VARCHAR(30),  
   consignee_city VARCHAR(18),  
   consignee_address   VARCHAR(40),  
   consignee_address2   VARCHAR(40),  
   consignee_zipcode   VARCHAR(10),  
   consignee_state VARCHAR(6),  
   consignee_phone   VARCHAR(20),  
   weight   FLOAT DEFAULT 0,  
   pieces   DECIMAL(10,2) DEFAULT 0,  
   hu    DECIMAL(10,2) DEFAULT 0,  
   hazardous   CHAR(1),  
   cod_amount  DECIMAL(9,2),  
   stp_sequence  INT,   
   bill_to   varchar(8),  
   bill_to_name VARCHAR(100),  
   bill_to_address VARCHAR(100),  
   bill_to_address2 VARCHAR(100),  
   bill_to_state VARCHAR(6),  
   bill_to_city VARCHAR(18),  
   bill_to_zipcode   VARCHAR(10),  
   BL VARCHAR(1000),  
   PO VARCHAR(1000),   
   svc_descriptions varchar(200),  
   TerminalID varchar(8),  
   signature_image image,   
   ord_terms varchar(6),  
   pickupdate datetime,  
   advanced varchar(50),  
   beyond varchar(50),  
   OrdServices varchar(Max), 
   cod_amount_type varchar(200),
   route_code varchar(10),
 );  
   
   
   
 --// order header search  
 IF COALESCE(@ord_hdrnumber,0) <> 0       
  BEGIN  
  
   INSERT INTO #dr(copy_id, copy_description,whosecopy, mfh_number, origin, mov_number,   
   stp_number, unit_id, ord_hdrnumber, eventcode, stp_sequence, stop_name, stop_city,  
   stop_state, hazardous, cod_amount, tractor, driver1, trailer1, trailer2, signature_image, pickupdate)  
    
   SELECT d.id, d.description, d.whosecopy, 0, s.cmp_id, s.mov_number, s.stp_number, s.trl_id, e.ord_hdrnumber, e.evt_eventcode, s.stp_sequence,  
   s.cmp_name, c.cty_name, c.cty_state, 'N', 0, lh.lgh_tractor, lh.lgh_driver1, lh.lgh_primary_trailer, lh.lgh_primary_pup,  
   ohl.signature_image,ord_origin_earliestdate  
  
   FROM #docs d, stops s WITH (NOLOCK)  
   INNER JOIN legheader lh WITH (NOLOCK) ON lh.mov_number = s.mov_number        
   INNER JOIN event e WITH (NOLOCK) ON e.stp_number = s.stp_number AND E.evt_eventcode IN ('LUL', 'DRL')  
   INNER JOIN orderheaderltlinfo ohl WITH (NOLOCK) on e.ord_hdrnumber = ohl.ord_hdrnumber  
   -- added 12-23-2013 Brian O'Sickey  
   INNER join orderheader ord WITH (NOLOCK) on ord.ord_hdrnumber = ohl.ord_hdrnumber  
   INNER JOIN city c WITH (NOLOCK) ON c.cty_code = ord.ord_destcity            
   where (e.ord_hdrnumber = @ord_hdrnumber)  
   ORDER BY s.stp_sequence;  
   
  END  
  
 --// manifest  
 ELSE IF COALESCE(@MfhNumber,0) <> 0  
   BEGIN  
     
   INSERT INTO #dr(copy_id, copy_description,whosecopy, mfh_number, origin, mov_number,   
    stp_number, unit_id, ord_hdrnumber, eventcode, stp_sequence, stop_name, stop_city,  
    stop_state, hazardous, cod_amount, tractor, driver1, trailer1, trailer2)  
  
   SELECT d.id, d.description, d.whosecopy, mh.mfh_number, mh.cmp_id, mh.mov_number, s.stp_number, mh.unit_id, e.ord_hdrnumber, e.evt_eventcode, s.stp_sequence,  
   s.cmp_name, c.cty_name, s.stp_state, 'N', 0, lh.lgh_tractor, lh.lgh_driver1, lh.lgh_primary_trailer, lh.lgh_primary_pup  
  
   FROM #docs d, stops s WITH (NOLOCK)
   INNER JOIN legheader lh WITH (NOLOCK) ON lh.mov_number = s.mov_number   
   INNER JOIN city c WITH (NOLOCK) ON c.cty_code = s.stp_city   
   INNER JOIN manifestheader mh WITH (NOLOCK) ON mh.mov_number = s.mov_number  
   INNER JOIN event e WITH (NOLOCK) ON e.stp_number = s.stp_number AND E.evt_eventcode IN ('LUL', 'DRL', 'XDU')  
   WHERE (mh.mfh_number = @MfhNumber)  
   ORDER BY s.stp_sequence;  
  
  END  
 --// delivery terminal and date  
 ELSE  
  BEGIN  
    INSERT INTO #dr(copy_id, copy_description,whosecopy, mfh_number, origin, mov_number,   
   stp_number, unit_id, ord_hdrnumber, eventcode, stp_sequence, stop_name, stop_city,  
   stop_state, hazardous, cod_amount, tractor, driver1, trailer1, trailer2, signature_image)  
    
   SELECT d.id, d.description, d.whosecopy, 0, s.cmp_id, s.mov_number, s.stp_number, s.trl_id, e.ord_hdrnumber, e.evt_eventcode, s.stp_sequence,  
   s.cmp_name, c.cty_name, s.stp_state, 'N', 0, lh.lgh_tractor, lh.lgh_driver1, lh.lgh_primary_trailer, lh.lgh_primary_pup,  
   ohl.signature_image  
  
   FROM #docs d, stops s WITH (NOLOCK)
   INNER JOIN legheader lh WITH (NOLOCK) ON lh.mov_number = s.mov_number   
   INNER JOIN city c WITH (NOLOCK) ON c.cty_code = s.stp_city   
   INNER JOIN event e WITH (NOLOCK) ON e.stp_number = s.stp_number AND E.evt_eventcode IN ('LUL', 'DRL')  
   inner join orderheaderltlinfo ohl WITH (NOLOCK) on e.ord_hdrnumber = ohl.ord_hdrnumber  
   INNER JOIN orderheader oh WITH (NOLOCK) on oh.ord_hdrnumber = ohl.ord_hdrnumber  
   WHERE ohl.delivery_terminal = @delivery_terminal  
   --AND ohl.pickup_terminal = @delivery_terminal   -- local only at this point  --commented as per Lee's request
   AND ord_status NOT IN ('QTE', 'MST', 'CMP', 'CAN', 'ICO', 'PND')  
   AND DAY(oh.ord_dest_earliestdate) = DAY(@delivery_date)  
   AND MONTH(oh.ord_dest_earliestdate) = MONTH(@delivery_date)  
   AND YEAR(oh.ord_dest_earliestdate) = YEAR(@delivery_date)  
   ORDER BY s.stp_sequence;  
  
   
  END;  
  
 DECLARE @weight FLOAT ;  
 DECLARE @pieces DECIMAL(10,2);  
 DECLARE @ordHdrNumber INT;  
 DECLARE @ordNumber VARCHAR(12);  
 DECLARE @eventCode VARCHAR(6);  
 DECLARE @COD MONEY;  
 DECLARE @shipperName VARCHAR(30);  
 DECLARE @shipperCity VARCHAR(18);  
 declare @shipper_address   VARCHAR(40);  
 declare @shipper_address2   VARCHAR(40);  
 declare @shipper_zipcode   VARCHAR(10);  
 DECLARE @shipperState VARCHAR(6);  
 DECLARE @shipper_id VARCHAR(8);  
 DECLARE @shipper_phone VARCHAR(20);  
 DECLARE @consigneeName VARCHAR(30);  
 declare @consignee_address   VARCHAR(40);  
 declare @consignee_address2   VARCHAR(40);  
 declare @consignee_zipcode   VARCHAR(10);  
 DECLARE @consigneeCity VARCHAR(18);  
 DECLARE @consigneeState VARCHAR(6);  
 DECLARE @consignee_phone VARCHAR(20);  
 DECLARE @Bill_To VARCHAR(8);  
 DECLARE @bill_to_name VARCHAR(100);  
 declare @bill_to_address VARCHAR(100);  
 declare @bill_to_address2 VARCHAR(100);  
 declare @bill_to_state VARCHAR(6);  
 declare @bill_to_cityid int;  
 declare @bill_to_city VARCHAR(18);  
 declare @bill_to_zipcode   VARCHAR(10);  
 declare @BL VARCHAR(1000);  
 declare @PO VARCHAR(1000);  
 declare @pro_number VARCHAR(30);  
 declare @svc_descriptions varchar(200);  
 declare @TerminalID varchar(8);   
 declare @ord_terms varchar(6);  
 declare @stp_number INT;  
 declare @pickupdate datetime;  
 declare @advanced varchar(50);  
 declare @beyond varchar(50);  
 declare @Service varchar(max);  
 declare @cod_amount_type varchar(200); 
 declare @route_code varchar(10);
 declare @unit_pos varchar(6);
 declare @route_id int;
 declare @route_id_override int;
  
 DECLARE c_order CURSOR FOR SELECT ord_hdrnumber, eventcode from #dr;  
  
 OPEN c_order;  
  
 FETCH c_order INTO @ordHdrNumber, @eventCode;  
  
 WHILE @@FETCH_STATUS = 0  
 BEGIN  
  
   IF @ordHdrNumber <> 0  
   BEGIN  
    
  --// Order header  
  SELECT @ordNumber = ord_number, @weight = ord_totalweight, @pieces = ord_totalpieces,  
         @COD = ord_cod_amount, @Bill_To = ord_billto, @ord_terms = ord_terms  
         FROM orderheader WITH (NOLOCK)
         where ord_hdrnumber = @ordHdrNumber;            
  
  --//Bill To Company  
  SELECT @bill_to_name = cmp_name, @bill_to_address = cmp_address1, @bill_to_address2 = cmp_address2, 
  @bill_to_state = cmp_state, @bill_to_cityid = cmp_city, @bill_to_zipcode = cmp_zip  
  from [company] WITH (NOLOCK) 
  where cmp_id = @Bill_To  
    
  select @bill_to_city = cty_name  
  from city WITH (NOLOCK)
  where cty_code = @bill_to_cityid  
    
  
  --// Shipper  
  SELECT @shipperName = s.cmp_name, @shipperCity = c.cty_name, @shipperState = s.stp_state, @shipper_id = s.cmp_id,  
  @shipper_phone = (select cmp_primaryphone 
  from company WITH (NOLOCK)
  where cmp_id = s.cmp_id),   
  @shipper_address = s.stp_address,@shipper_address2 = s.stp_address2, @shipper_zipcode = s.stp_zipcode  
  FROM stops s WITH (NOLOCK), event e WITH (NOLOCK) , city c WITH (NOLOCK) 
  where e.ord_hdrnumber = @ordHdrNumber  
  AND e.stp_number = s.stp_number AND e.evt_eventcode IN ( 'LLD', 'HPL')  
  AND c.cty_code = s.stp_city;  
  
  --// Consignee  
  SELECT @consigneeName = s.cmp_name, @consigneeCity = c.cty_name, @consigneeState = c.cty_state,  
  @consignee_phone = (select cmp_primaryphone 
  from company WITH (NOLOCK)
  where cmp_id = s.cmp_id),  
  @consignee_address = s.stp_address, @consignee_address2 = s.stp_address2, 
  --@consignee_zipcode = s.stp_zipcode,  
  @consignee_zipcode = ord.ord_dest_zip,  -- fixing bug because stop zip is not too reliable at this point (Anvar, Langley)
  @stp_number = s.stp_number  
  FROM stops s   
   -- change 12-23-2013 Brian O'Sickey  
   inner join event e WITH (NOLOCK) on e.stp_number = s.stp_number AND e.evt_eventcode IN ( 'LUL', 'DRL')  
   INNER join orderheader ord WITH (NOLOCK) on ord.ord_hdrnumber = @ordHdrNumber  
   INNER JOIN city c WITH (NOLOCK) ON c.cty_code = ord.ord_destcity  
     
  where e.ord_hdrnumber = @ordHdrNumber;  
    
  --//TerminalID extraction (delivery)  
  --SELECT @TerminalID = s.cmp_id  
  --FROM stops s   
  --INNER JOIN event e ON e.stp_number = s.stp_number  
  --INNER JOIN city c ON c.cty_code = s.stp_city  
  --WHERE e.ord_hdrnumber = @ordHdrNumber AND s.stp_type = 'NONE';  
  SELECT @TerminalID = orderheaderltlinfo.delivery_terminal  
  FROM orderheaderltlinfo  WITH (NOLOCK)
  WHERE orderheaderltlinfo.ord_hdrnumber = @ordHdrNumber  
          
  ----BL  
  --SELECT @BL = MAX(ref_number)   
  --FROM referencenumber  WITH (NOLOCK)
  --where ref_type = 'BL#' and ref_table = 'orderheader'  
  --and ref_tablekey = @ordHdrNumber  
  
  --New and improved BL for multiple values
    SELECT ref_number, 1 as ID  
 into #BL  
 FROM referencenumber  WITH (NOLOCK)
 where ref_type = 'BL#' and ref_table = 'orderheader'  
 and ref_tablekey = @ordHdrNumber

 select  @BL = MAX(STUFF(t2.ID,1,1,''))  
 FROM #BL t1  
 CROSS apply(  
 SELECT ',' + t2.ref_number  
 FROM #BL t2  
 WHERE t2.ID = t1.ID AND t2.ref_number > ''  
 FOR xml PATH('')  
 ) AS t2 (ID)  
 GROUP BY  
 t1.id  
  
    drop table #BL  
    
  ----PO  
  --SELECT @PO = MAX(ref_number)   
  --FROM referencenumber  WITH (NOLOCK)
  --where ref_type = 'PO#' and ref_table = 'orderheader'  
  --and ref_tablekey = @ordHdrNumber  
  
 --New and improved PO for multiple values
 SELECT ref_number, 1 as ID  
 into #PO   
 FROM referencenumber  WITH (NOLOCK)
 where ref_type = 'PO#' and ref_table = 'orderheader'  
 and ref_tablekey = @ordHdrNumber

 select  @PO = MAX(STUFF(t2.ID,1,1,''))  
 FROM #PO t1  
 CROSS apply(  
 SELECT ',' + t2.ref_number  
 FROM #PO t2  
 WHERE t2.ID = t1.ID AND t2.ref_number > ''  
 FOR xml PATH('')  
 ) AS t2 (ID)  
 GROUP BY  
 t1.id  
  
    drop table #PO  
    
  --Pro  
  SELECT @pro_number = MAX(ref_number)   
  FROM referencenumber  WITH (NOLOCK)
  where ref_type = 'PRO#' and ref_table = 'orderheader'  
  and ref_tablekey = @ordHdrNumber  
    
  --  
  select @pickupdate = MAX(ord_origin_earliestdate)  
  from orderheader WITH (NOLOCK)
  where ord_hdrnumber = @ordHdrNumber  
    
  select @advanced =  max(ord_booked_carrier)  
  from legheader_brokered WITH (NOLOCK)  
  where lgh_number in (select distinct lgh_number   
      from stops s  WITH (NOLOCK)
      INNER JOIN event e WITH (NOLOCK) ON e.stp_number = s.stp_number AND E.evt_eventcode IN ( 'LLD', 'HPL')  
      INNER JOIN orderheaderltlinfo ohl WITH (NOLOCK) on e.ord_hdrnumber = ohl.ord_hdrnumber  
     where ohl.ord_hdrnumber = @ordHdrNumber)  
       
  
  select @beyond =  max(ord_booked_carrier)  
  from legheader_brokered   WITH (NOLOCK)
  where lgh_number in (select distinct lgh_number   
      from stops s  WITH (NOLOCK)
      INNER JOIN event e WITH (NOLOCK) ON e.stp_number = s.stp_number AND E.evt_eventcode IN ('LUL', 'DRL')   
      INNER JOIN orderheaderltlinfo ohl WITH (NOLOCK) on e.ord_hdrnumber = ohl.ord_hdrnumber  
     where ohl.ord_hdrnumber = @ordHdrNumber)       
  
  
  select @Service = dbo.fnc_OrderService(@ordHdrNumber)  
    
  -------------svc_descriptions ----------------------------------------------  
    
  SELECT distinct(svc_description), 1 as ID  
  into #temp   
  FROM order_services os WITH (NOLOCK) INNER JOIN services s WITH (NOLOCK) on os.svc_code = s.svc_code  
  WHERE ord_hdrnumber = @ordHdrNumber  
    
   select  @svc_descriptions = MAX(STUFF(t2.ID,1,1,''))  
   FROM #temp t1  
   CROSS apply(  
    SELECT ', ' + t2.svc_description  
    FROM #temp t2  
    WHERE t2.ID = t1.ID AND t2.svc_description > ''  
    FOR xml PATH('')  
   ) AS t2 (ID)  
   GROUP BY  
    t1.id  
  
  
   
  drop table #temp  
     
  
  -------------end of svc_descriptions ---------------------------------------  
  
  
  -------------Beginning of COD Amount ----------------------------------------
  if @COD is NULL
  BEGIN    
    
  select @COD = cod_amount, 
  @cod_amount_type = payment_type  
  from cod WITH (NOLOCK)
  where ord_hdrnumber = @ordHdrNumber

  SELECT * into #COD
  FROM dbo.CSVStringsToTable_fn_seq
   (
    @cod_amount_type
   )
   
  --select * from #COD  
  
  declare @CODresult varchar(200) = null --important to assign to null to make sure types don't double up in this variable
     
  select @CODresult = COALESCE(@CODresult+', '+A.value, A.value)
    FROM (  
     select  value = 
      CASE value 
       WHEN 'BD' THEN 'Bank Draft'
       WHEN 'CCHQ' THEN 'Certified Check'
       WHEN 'CHQ' THEN 'Check'
       WHEN 'CC' THEN 'Credit Card'
       WHEN 'CSH' THEN 'Cash'
       ELSE 'Unknown payment type' --that option would kick in if some new COD payment method is introduced (Anvar, Langley)
      END
     from #COD 
    ) A      
  
  select @cod_amount_type = @CODresult   
                
  drop table #COD     
 
  END   
  -------------End of COD Amount ---------------------------------------------- 
  
  -------------Delivery route and unit position
  select @unit_pos = unit_pos, @route_id = route_id,
    @route_id_override = route_id_override from stopltlinfo
    where stp_number = @stp_number
    
    IF @route_id_override <> 0
    BEGIN
      select @route_code = route_code from terminalroute where id = @route_id_override;
    END
    ELSE
    BEGIN
      select @route_code = route_code from terminalroute where id = @route_id;
    END
  
  -------------End of delivery route and unit position
  
  
  UPDATE #dr SET weight = @weight, pieces = @pieces, cod_amount = @COD,  
   ord_number = @ordNumber,   
   shipper_name = @shipperName, shipper_city = @shipperCity, shipper_state = @shipperState,   
   shipper_id = @shipper_id, shipper_phone = @shipper_phone, shipper_address = @shipper_address,shipper_address2 = @shipper_address2,
   shipper_zipcode = @shipper_zipcode,  
   consignee_name = @consigneeName, consignee_address = @consignee_address, consignee_address2 = @consignee_address2,
   consignee_zipcode = @consignee_zipcode,  
   consignee_city = @consigneeCity, consignee_state = @consigneeState,  
   consignee_phone = @consignee_phone,   
   bill_to = @Bill_To, bill_to_name = @bill_to_name, bill_to_address = @bill_to_address,bill_to_address2 = @bill_to_address2,
   bill_to_state = @bill_to_state, bill_to_city = @bill_to_city, bill_to_zipcode = @bill_to_zipcode,  
   BL=@BL, PO=@PO, pro_number=@pro_number, svc_descriptions=@svc_descriptions, TerminalID = @TerminalID,  
   ord_terms = @ord_terms,  
   stp_number = @stp_number,  
   pickupdate = @pickupdate,  
   advanced = @advanced,  
   beyond = @beyond,  
   OrdServices = @Service,
   cod_amount_type = @cod_amount_type,
   route_code = @route_code,
   unit_pos = @unit_pos 
  
  WHERE ord_hdrnumber = @ordHdrNumber;  
              
   END;  
  
   FETCH c_order INTO @ordHdrNumber, @eventCode;  
  
 END;  
  
 CLOSE c_order;  
 DEALLOCATE c_order;  
   
 IF COALESCE(@MfhNumber,0) <> 0  
 BEGIN  
  SELECT *  FROM #dr order by stp_sequence, copy_id;  
    END  
 ELSE  
 BEGIN  
  SELECT *  FROM #dr order by ord_hdrnumber, copy_id;  
 END;  
 drop table #dr  
  
RETURN 0  
END
GO
GRANT EXECUTE ON  [dbo].[RptDeliveryReceipt] TO [public]
GO
