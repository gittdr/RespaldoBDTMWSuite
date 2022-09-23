SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* Example:
CarrierAuctionGetMessageParameters_sp     604
*/
CREATE PROCEDURE [dbo].[CarrierAuctionGetMessageParameters_sp] 
 @cb_id                  int
AS
BEGIN
      DECLARE @ord_hdrnumber int  
      DECLARE @lgh_number int  
  
      DECLARE @Resultset TABLE(  
            ca_id                   int                     NULL,  
            cb_id                   int                     NULL,  
            ca_description          varchar(255)      NULL,  
            ord_hdrnumber           int                     NULL,  
            lgh_number              int                     NULL,  
            mov_number              int                     NULL,  
            ca_end_date             datetime          NULL,  
            ca_type                       varchar(6)        NULL,  
            ca_auction_amount money             NULL,  
            cb_sent_expires         datetime          NULL,  
            lgh_startcity           int                     NULL,  
            lgh_endcity             int                     NULL,  
            cmp_id_start            varchar(12)       NULL,  
            cmp_id_end              varchar(12)   NULL,  
            lgh_schdtearliest datetime     NULL,  
            lgh_schdtlatest         datetime   NULL,  
            cmd_code                varchar(8)   NULL,  
            fgt_description         varchar(60)   NULL,  
            lgh_startcty_nmstct     varchar(25)   NULL,  
            lgh_endcty_nmstct  varchar(25)   NULL,  
   car_id                  varchar(8)   NULL,  
   ShipperID    varchar(8)   null,  
   ShipperName             varchar(100)  null,  
   ShipperAddress1         varchar(100)  null,  
   ShipperAddress2         varchar(100)  null,  
   ShipperCity             varchar(18)   null,  
   ShipperState            varchar(6)   null,  
   ShipperZip    varchar(10)   null,  
   ConsigneeID    varchar(8)   null,   
   ConsigneeName           varchar(100)  null,  
   ConsigneeAddress1       varchar(100)  null,  
   ConsigneeAddress2       varchar(100)  null,  
   ConsigneeCity           varchar(18)   null,  
   ConsigneeState          varchar(6)   null,  
   ConsigneeZip   varchar(10)   null,  
   FirstLoadedStopID  varchar(8)   null,   
   FirstLoadedStopName     varchar(100)  null,  
   FirstLoadedStopAddress1 varchar(100)  null,  
   FirstLoadedStopAddress2 varchar(100)  null,  
   FirstLoadedStopCity     varchar(18)   null,  
   FirstLoadedStopState    varchar(6)   null,  
   FirstLoadedStopZip  varchar(10)   null,  
   LastLoadedStopID  varchar(8)   null,   
   LastLoadedStopName     varchar(100)   null,  
   LastLoadedStopAddress1 varchar(100)   null,  
   LastLoadedStopAddress2 varchar(100)   null,  
   LastLoadedStopCity     varchar(18)   null,  
   LastLoadedStopState    varchar(6)   null,  
   LastLoadedStopZip  varchar(10)   null  
         
      )  
  
      INSERT INTO @Resultset(  
                  ca_id,  
                  cb_id,  
                  ca_description,  
                  ord_hdrnumber,  
                  lgh_number,  
                  ca_end_date,  
                  ca_type,  
                  ca_auction_amount,  
                  cb_sent_expires,  
                  car_id              
      )  
      SELECT      cb.ca_id,  
                  cb.cb_id,  
                  ca.ca_description,  
                  ca.ord_hdrnumber,  
                  ca.lgh_number,  
                  ca.ca_end_date,  
                  ca.ca_type,  
                  ca.ca_auction_amount,  
                  cb_sent_expires,  
                  cb.car_id  
          
      FROM  carrierbids cb inner join carrierauctions ca on (cb.ca_id = ca.ca_id)  
      WHERE (cb_id = @cb_id)  
  
      SELECT @ord_hdrnumber = ord_hdrnumber,  
                  @lgh_number = lgh_number  
      FROM @Resultset  
          
                    
      IF isnull(@lgh_number, 0) = 0 BEGIN  
            SELECT  @lgh_number = lgh.lgh_number  
            FROM orderheader ord inner join legheader lgh on ord.mov_number = lgh.mov_number  
            WHERE ord.ord_hdrnumber = @ord_hdrnumber  
      END  
  
      UPDATE @Resultset  
      SET   
  
                  mov_number = lgh.mov_number,  
                  lgh_startcity=    lgh.lgh_startcity,  
                        lgh_endcity=lgh.lgh_endcity,  
                        cmp_id_start=lgh.cmp_id_start,  
                        cmp_id_end=lgh.cmp_id_end,  
                        lgh_schdtearliest=lgh.lgh_schdtearliest,  
                        lgh_schdtlatest=lgh.lgh_schdtlatest,  
                        cmd_code=lgh.cmd_code,  
                        fgt_description=lgh.fgt_description,  
                        lgh_startcty_nmstct=lgh.lgh_startcty_nmstct,  
                        lgh_endcty_nmstct=lgh.lgh_endcty_nmstct  
      FROM        legheader lgh   
      WHERE       (lgh.lgh_number = @lgh_number )        
        
      UPDATE @Resultset  
      SET   
      ShipperID    = hdr.ord_shipper,  
      ConsigneeID  = hdr.ord_consignee         
      from orderheader hdr where hdr.ord_hdrnumber = @ord_hdrnumber         
        
      UPDATE @Resultset  
      SET   
        ShipperName   = cmp_name,          
        ShipperAddress1  = cmp_address1,             
        ShipperAddress2  = cmp_address2,              
        ShipperCity   = cty_name,      
        ShipperState  = cty_state,        
        ShipperZip   = cty_zip         
          from company cmp, city              
          where cmp_id = (select shipperid from @Resultset)  
          and cty_code = cmp_city  
            
      UPDATE @Resultset  
      SET   
        ConsigneeName   = cmp_name,          
        ConsigneeAddress1  = cmp_address1,             
        ConsigneeAddress2  = cmp_address2,              
        ConsigneeCity   = cty_name,      
        ConsigneeState   = cty_state,        
        ConsigneeZip   = cty_zip         
          from company cmp, city              
          where cmp_id = (select consigneeid from @Resultset)  
          and cty_code = cmp_city  
  --------------------------------------------first loaded stop:        
    DECLARE @FreightStopCompanyID varchar(8)  
     
   --select @FreightStopCompanyID  = cmp_id from stops  
   --where stp_mfh_sequence = (select min (stp_mfh_sequence) from stops  
   --     where stops.ord_hdrnumber = @ord_hdrnumber and stp_type = 'PUP') 
        
   select @FreightStopCompanyID =cmp_id  
   from 
   (select cmp_id, row_number() over (order by stp_mfh_sequence, stp_arrivaldate) RN
    from stops where ord_hdrnumber = @ord_hdrnumber and stp_type = 'PUP')  subq
   where rn = 1         
    
       UPDATE @Resultset  
      SET   
  FirstLoadedStopID = @FreightStopCompanyID,  
        FirstLoadedStopName   = cmp_name,          
        FirstLoadedStopAddress1  = cmp_address1,             
        FirstLoadedStopAddress2  = cmp_address2,              
        FirstLoadedStopCity   = cty_name,      
        FirstLoadedStopState  = cty_state,        
        FirstLoadedStopZip   = cty_zip         
          from company, city              
          where cmp_id = @FreightStopCompanyID  
          and cty_code = cmp_city  
    --------------------------------------------last loaded stop:            
   --select @FreightStopCompanyID  = cmp_id from stops  
   --where stp_mfh_sequence = (select max (stp_mfh_sequence) from stops  
   --     where stops.ord_hdrnumber = @ord_hdrnumber and stp_type = 'DRP')  

   select @FreightStopCompanyID =cmp_id  
   from 
   (select cmp_id, row_number() over (order by stp_mfh_sequence desc, stp_arrivaldate desc) RN
    from stops where ord_hdrnumber = @ord_hdrnumber and stp_type = 'DRP')  subq
   where rn = 1    
     
       UPDATE @Resultset  
      SET   
  LastLoadedStopID = @FreightStopCompanyID,  
        LastLoadedStopName   = cmp_name,          
        LastLoadedStopAddress1  = cmp_address1,             
        LastLoadedStopAddress2  = cmp_address2,              
        LastLoadedStopCity   = cty_name,      
        LastLoadedStopState   = cty_state,        
        LastLoadedStopZip   = cty_zip         
          from company, city              
          where cmp_id = @FreightStopCompanyID  
          and cty_code = cmp_city  
            
      SELECT   
                  ca_id,  
                  cb_id,  
                  ca_description,  
                  ord_hdrnumber,  
                  lgh_number,  
                  mov_number,  
                  ca_end_date,  
                  ca_type,  
                  ca_auction_amount,  
                  cb_sent_expires,  
                  lgh_startcity,  
                  lgh_endcity,  
                  cmp_id_start,  
                  cmp_id_end,  
                  lgh_schdtearliest,  
                  lgh_schdtlatest,  
                  cmd_code,  
                  fgt_description,  
                  lgh_startcty_nmstct,  
                  lgh_endcty_nmstct,  
                  car_id,  
     ShipperID,  
     ShipperName,   
     ShipperAddress1,     
     ShipperAddress2,    
     ShipperCity,        
     ShipperState,      
     ShipperZip,   
     ConsigneeID,    
     ConsigneeName,   
     ConsigneeAddress1,     
     ConsigneeAddress2,    
     ConsigneeCity,        
     ConsigneeState,      
     ConsigneeZip,   
     FirstLoadedStopID,    
     FirstLoadedStopName,   
     FirstLoadedStopAddress1,     
     FirstLoadedStopAddress2,    
     FirstLoadedStopCity,        
     FirstLoadedStopState,      
     FirstLoadedStopZip,   
     LastLoadedStopID,    
     LastLoadedStopName,   
     LastLoadedStopAddress1,     
     LastLoadedStopAddress2,    
     LastLoadedStopCity,        
     LastLoadedStopState,      
     LastLoadedStopZip       
      FROM @Resultset   
     
END

GO
GRANT EXECUTE ON  [dbo].[CarrierAuctionGetMessageParameters_sp] TO [public]
GO
