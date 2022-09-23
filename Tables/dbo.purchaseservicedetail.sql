CREATE TABLE [dbo].[purchaseservicedetail]
(
[psh_number] [int] NOT NULL,
[psd_number] [int] NOT NULL IDENTITY(100, 1),
[psd_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psd_qty] [float] NULL,
[psd_estrate] [money] NULL,
[psd_rate] [money] NULL,
[psd_heelqty] [float] NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psd_ref_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psd_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_purchaseservicedetail] ON [dbo].[purchaseservicedetail] FOR UPDATE AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
DECLARE @psh_number int

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

SELECT @psh_number = psh_number
    FROM inserted
BEGIN
     UPDATE purchaseserviceheader
              SET psh_updatedby = UPPER(@tmwuser),
                        psh_updatedon = GETDATE()
       WHERE psh_number = @psh_number
END

GO
ALTER TABLE [dbo].[purchaseservicedetail] ADD CONSTRAINT [AutoPK_purchaseservicedetail] PRIMARY KEY CLUSTERED ([psd_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_psh_number] ON [dbo].[purchaseservicedetail] ([psh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[purchaseservicedetail] TO [public]
GO
GRANT INSERT ON  [dbo].[purchaseservicedetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[purchaseservicedetail] TO [public]
GO
GRANT SELECT ON  [dbo].[purchaseservicedetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[purchaseservicedetail] TO [public]
GO
