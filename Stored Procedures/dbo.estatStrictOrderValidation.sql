SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[estatStrictOrderValidation]  @ordersin varchar(MAX), @login varchar(132)
-- 58932/4407 
-- Takes a comma-separated list of order numbers and for each order checks to see
-- that order meets this criteria: do at any of the user's profile companies
-- occur on the order as shipper, consignee, orderby, billto, stop company, 
-- or fgt_shipper or fgt_consignee on a freight item on any stop.
-- It returns a comma-separated list of the orders that meet this criteria.   
-- Sample exec: estatStrictOrderValidation '673 , 674, 675, 676, 677,  678', 'user1'  
AS
SET NOCOUNT ON
DECLARE @OrdNumList varchar(MAX)
SET @OrdNumList = @ordersin 
DECLARE @Delimeter char(1)
SET @Delimeter = ','

--The list of orders to be returned
declare  @ordersout varchar(MAX)
select @ordersout = ''

--Parse the string and check each order to see if it meets above criteria.
--If so, concatenate to the return list. 
DECLARE @OrdNum    varchar(12)             
DECLARE @StartPos int, @Length int
WHILE LEN(@OrdNumList) > 0
  BEGIN
    SET @StartPos = CHARINDEX(@Delimeter, @OrdNumList)
    IF @StartPos < 0 SET @StartPos = 0
    SET @Length = LEN(@OrdNumList) - @StartPos - 1
    IF @Length < 0 SET @Length = 0
    IF @StartPos > 0
      BEGIN -- the beginning or middle of list:
        SET @OrdNum = SUBSTRING(@OrdNumList, 1, @StartPos - 1)
        SET @OrdNumList = SUBSTRING(@OrdNumList, @StartPos + 1, LEN(@OrdNumList) - @StartPos)
      END
    ELSE
      BEGIN -- this is the last one in the list
        SET @OrdNum = @OrdNumList     
        SET @OrdNumList = ''       
      END
      select @OrdNum = LTRIM(RTRIM(@OrdNum))          
      -- if profile company is orderby, shipper, consignee, or billto
      if exists ( select 1 from orderheader where ord_hdrnumber = @OrdNum  
                and (
                ord_company in (select cmp_id from estatusercompanies where login = @login)
                or ord_shipper in (select cmp_id from estatusercompanies where login = @login)
                or ord_consignee in (select cmp_id from estatusercompanies where login = @login)
                or ord_billto in (select cmp_id from estatusercompanies where login = @login)
                )    )    
					select  @ordersout =  @ordersout + @OrdNum  + ','  -- return the order number
      else
               begin  
					-- if profile company is a stop or a freigh shipper or freigh consignee 
					If exists (select * from freightdetail f, stops s where f.stp_number = s.stp_number and s.ord_hdrnumber = @OrdNum and (f.fgt_shipper in (select cmp_id from estatusercompanies where login = @login) or f.fgt_consignee in (select cmp_id from estatusercompanies where login = @login)))
					or exists (select * from stops where stops.ord_hdrnumber = @OrdNum and stops.cmp_id in (select cmp_id from estatusercompanies where login = @login))
					select  @ordersout =  @ordersout + @OrdNum  + ','              
               end   
END
if DATALENGTH(@ordersout)>0 
select left (@ordersout, datalength(@ordersout) - 1) as orders -- remove trailing coma
else
begin
select @ordersout
end



GO
GRANT EXECUTE ON  [dbo].[estatStrictOrderValidation] TO [public]
GO
