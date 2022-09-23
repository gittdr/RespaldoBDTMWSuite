SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[edi_tendertocarrier]
	@ordnum varchar(12),
	@carrier varchar(8),
	@revtype1 varchar(20),
	@revtype2 varchar(20),
	@revtype3 varchar(20),
	@revtype4 varchar(20),
	@retcode int OUTPUT,
	@ordstate int OUTPUT,
	@result varchar(80) OUTPUT
as

DECLARE @v_revtype1 varchar(6), @v_revtype2 varchar(6), @v_revtype3 varchar(6), @v_revtype4 varchar(6),
	@v_cmpident int, @v_drqtype varchar(6), @v_edistate varchar(6), @v_carrier varchar(8), 
	@v_ordhdr int, @v_mov int, @v_evt int, @v_status varchar(6)

SELECT @retcode = 0

IF ISNULL(@ordnum, 0) = 0 RETURN

SELECT @v_ordhdr = ord_hdrnumber, @v_mov = mov_number, @v_edistate = ord_edistate, @v_carrier = ord_carrier
  FROM orderheader
 WHERE ord_number = @ordnum

IF ISNULL(@v_mov, 0) = 0 RETURN

SELECT @retcode = -1, @ordstate = convert(int, @v_edistate), @result = ''

IF ISNULL(@v_edistate,'') = '' 
BEGIN
	SELECT @result = 'Missing EDI state on this order'
	RETURN
END

IF @revtype1 = 'UNKNOWN'
	SELECT @v_revtype1 = 'UNK'
ELSE
	SELECT @v_revtype1 = abbr
	  FROM labelfile WITH (NOLOCK)
	 WHERE labeldefinition = 'RevType1' AND [name] = @revtype1

IF @revtype2 = 'UNKNOWN'
	SELECT @v_revtype2 = 'UNK'
ELSE
	SELECT @v_revtype2 = abbr
	  FROM labelfile WITH (NOLOCK)
	 WHERE labeldefinition = 'RevType2' AND [name] = @revtype2

IF @revtype3 = 'UNKNOWN'
	SELECT @v_revtype3 = 'UNK'
ELSE
	SELECT @v_revtype3 = abbr
	  FROM labelfile WITH (NOLOCK)
	 WHERE labeldefinition = 'RevType3' AND [name] = @revtype3

IF @revtype4 = 'UNKNOWN'
	SELECT @v_revtype4 = 'UNK'
ELSE
	SELECT @v_revtype4 = abbr
	  FROM labelfile WITH (NOLOCK)
	 WHERE labeldefinition = 'RevType4' AND [name] = @revtype4

IF ISNULL(@carrier,'UNKNOWN') <> 'UNKNOWN'
BEGIN
	IF (SELECT UPPER(SUBSTRING(gi_string1, 1,1)) 
		      FROM generalinfo WITH (NOLOCK) 
		     WHERE gi_name = 'ProcessOutbound204') = 'Y'
	BEGIN
		/* EXEC @v_cmpident = dx_EDIUnmatchedCompanyIdent @v_ordhdr
		If @v_cmpident > 0
		BEGIN
			SELECT @result = 'Unmatched companies exist on this order.  Correct in Trip Folder.'
			RETURN
		END */
		SELECT @v_drqtype = drq_type
		  FROM driverqualifications
		 WHERE drq_id = @carrier
		   AND drq_type = ISNULL(@v_revtype1,'UNK')
		IF ISNULL(@v_revtype1,'UNK') <> ISNULL(@v_drqtype,'UNK')
		BEGIN
			SELECT @result = 'Carrier ' + @carrier + ' can not be tendered to ' + @revtype1 + ' orders'
			RETURN
		END
	END
END

IF ISNULL(@v_carrier,'UNKNOWN') <> ISNULL(@carrier,'UNKNOWN')
BEGIN
	IF @carrier = 'UNKNOWN'
	BEGIN
		IF @ordstate IN (12,22,32)
			SELECT @v_status = 'PND', @ordstate = 10
		ELSE
			SELECT @v_status = 'AVL'
		SELECT @result = 'Removed tender from carrier ' + @v_carrier
	END
	ELSE
	BEGIN
		SELECT @v_status = 'PLN'
		IF (SELECT ISNULL(car_204flag,0) FROM carrier WHERE car_id = @carrier) <> 1
		BEGIN
			IF @ordstate IN (12,22,32) SELECT @ordstate = 10
			SELECT @result = 'Planned onto non-EDI carrier ' + @carrier
		END
		ELSE
			SELECT @ordstate = 12, @result = 'Tendered to EDI carrier ' + @carrier
	END
	IF @ordstate <> 12
	BEGIN
		SELECT @v_evt = 0
		WHILE 1=1
		BEGIN
			SELECT @v_evt = MIN(evt_number) FROM event WHERE evt_mov_number = @v_mov AND evt_number > @v_evt
			IF @v_evt IS NULL BREAK
			UPDATE event
			   SET evt_carrier = @carrier
			 WHERE evt_number = @v_evt
		END
		UPDATE orderheader SET ord_carrier = ISNULL(@carrier,'UNKNOWN') WHERE ord_number = @ordnum
		EXEC dx_EDI_OrderState_Update @v_ordhdr, @ordstate, @v_status
	END
END
ELSE
	SELECT @result = 'Updated, but no change to carrier detected'

UPDATE orderheader
   SET ord_revtype1 = ISNULL(@v_revtype1,'UNK')
     , ord_revtype2 = ISNULL(@v_revtype2,'UNK')
     , ord_revtype3 = ISNULL(@v_revtype3,'UNK')
     , ord_revtype4 = ISNULL(@v_revtype4,'UNK')
--     , ord_carrier = @carrier
 WHERE ord_number = @ordnum
   AND (ord_revtype1 <> ISNULL(@v_revtype1,'UNK') 
	OR ord_revtype2 <> ISNULL(@v_revtype2,'UNK')
	OR ord_revtype3 <> ISNULL(@v_revtype3,'UNK') 
	OR ord_revtype4 <> ISNULL(@v_revtype4,'UNK'))
--	OR ISNULL(@v_carrier,'UNKNOWN') <> ISNULL(@carrier,'UNKNOWN'))

IF @@ROWCOUNT > 0
	EXEC update_move_light @v_mov

SELECT @retcode = 1

RETURN

GO
GRANT EXECUTE ON  [dbo].[edi_tendertocarrier] TO [public]
GO
