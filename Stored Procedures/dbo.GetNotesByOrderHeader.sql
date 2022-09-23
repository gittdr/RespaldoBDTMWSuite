SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetNotesByOrderHeader]
 -- Add the parameters for the stored procedure here
 @OrderHeaderNumber int
AS
BEGIN
 -- SET NOCOUNT ON added to prevent extra result sets from
 -- interfering with SELECT statements.
 SET NOCOUNT ON;
declare @orderCarrier varchar(8)
declare @CommodityCode varchar(8)
declare @Company varchar(8)
declare @MovementNumber int
declare @Tractor varchar(8)
declare @Trailer varchar(8)
--declare @Driver ask about this is this driver 1 and driver 2 or broker?

Select @orderCarrier = ord_carrier,
       @CommodityCode = cmd_code,
       @Company = ord_company,
       @MovementNumber = mov_number,
       @Tractor = ord_tractor,
       @Trailer = ord_trailer from orderheader  WITH(NOLOCK) where ord_hdrnumber like(@OrderHeaderNumber)
    

SELECT * from Notes WITH(NOLOCK) where (ntb_table like('orderheader') and nre_tablekey like(@OrderHeaderNumber)) or
 (ntb_table like('carrier') and nre_tablekey like(@orderCarrier))  or
 (ntb_table like('commodity') and nre_tablekey like(@CommodityCode)) or 
 (ntb_table like('company') and nre_tablekey like(@Company)) or
 (ntb_table like('movement') and nre_tablekey like(@MovementNumber)) or
 (ntb_table like('tractorprofile') and nre_tablekey like(@Tractor)) or
 (ntb_table like('trailerprofile') and nre_tablekey like(@Trailer))  or
 (ntb_table like('stops') and nre_tablekey in(select stp_number from stops with (nolock) where ord_hdrnumber like(@OrderHeaderNumber)))
END
GO
GRANT EXECUTE ON  [dbo].[GetNotesByOrderHeader] TO [public]
GO
