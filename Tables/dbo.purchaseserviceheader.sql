CREATE TABLE [dbo].[purchaseserviceheader]
(
[psh_id] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[psh_number] [int] NOT NULL,
[psh_vendor_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psh_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psh_promised_dt] [datetime] NULL,
[psh_pickup_dt] [datetime] NULL,
[psh_drop_dt] [datetime] NULL,
[ord_hdrnumber] [int] NULL,
[psh_service] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_number] [int] NULL,
[psh_batch_number] [int] NULL,
[psh_createdby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psh_createdon] [datetime] NULL,
[psh_updatedby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psh_updatedon] [datetime] NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_ref_invoice] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_ref_invoicedate] [datetime] NULL,
[trc_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psh_ref_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psh_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_purchaseserviceheader] ON [dbo].[purchaseserviceheader] FOR INSERT, UPDATE AS
	--PTS 55626 JJF 20110816
	--DECLARE @pshid varchar(12),
	DECLARE	@pshid varchar(17)
	--END PTS 55626 JJF 20110816
	DECLARE	@psh_number int

	--PTS 23691 CGK 9/3/2004
	DECLARE @tmwuser varchar (255)
	
	SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
	
	exec gettmwuser @tmwuser output

	SELECT @pshid = psh_id,
	@psh_number = psh_number
	FROM deleted
	
	IF @pshid is null /*Must be an insert*/
	BEGIN
		SELECT	@pshid = psh_id,
				@psh_number = psh_number
		FROM	inserted
		
		UPDATE	purchaseserviceheader
		SET		psh_createdby = UPPER(@tmwuser),
				psh_createdon = GETDATE(),
				psh_updatedby = UPPER(@tmwuser),
				psh_updatedon = GETDATE()
		WHERE	psh_number = @psh_number
	END
	ELSE
	BEGIN
		SELECT	@pshid = psh_id,
				@psh_number = psh_number
		FROM	inserted

		UPDATE	purchaseserviceheader
		SET		psh_updatedby = UPPER(@tmwuser),
				psh_updatedon = GETDATE()
		WHERE	psh_number = @psh_number
	END

GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_psh_number] ON [dbo].[purchaseserviceheader] ([psh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[purchaseserviceheader] TO [public]
GO
GRANT INSERT ON  [dbo].[purchaseserviceheader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[purchaseserviceheader] TO [public]
GO
GRANT SELECT ON  [dbo].[purchaseserviceheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[purchaseserviceheader] TO [public]
GO
