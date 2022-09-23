SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[dx_EDI_Carrier_Update]
	@p_OrderNumber int,
	@p_Carrier varchar(12)

as

DECLARE @v_evt INT, @v_mov INT, @v_ret INT

SELECT @v_evt = 0
SELECT @v_mov = mov_number FROM orderheader WHERE ord_hdrnumber = @p_OrderNumber

IF @v_mov IS NULL RETURN -1

IF ISNULL(@p_Carrier,'') IN ('','UNKNOWN')
	RETURN -2
ELSE
BEGIN
	IF (SELECT COUNT(1) FROM carrier WHERE car_id = @p_Carrier) = 0 RETURN -2
END

WHILE 1=1
BEGIN
	SELECT @v_evt = MIN(evt_number) FROM event WHERE evt_mov_number = @v_mov AND evt_number > @v_evt
	IF @v_evt IS NULL BREAK
	UPDATE event
	   SET evt_carrier = @p_Carrier
	 WHERE evt_number = @v_evt
END

UPDATE orderheader SET ord_carrier = ISNULL(@p_Carrier,'UNKNOWN') WHERE ord_hdrnumber = @p_OrderNumber
SELECT @v_ret = @@ROWCOUNT

/* FMM 7/17/2008 -- called directly in LTSL2 Interface so this proc can be used in DX
IF @v_ret = 1
	EXEC @v_ret = dbo.dx_EDI_OrderState_Update @p_OrderNumber, 12, 'PLN'
*/	

return @v_ret

GO
GRANT EXECUTE ON  [dbo].[dx_EDI_Carrier_Update] TO [public]
GO
