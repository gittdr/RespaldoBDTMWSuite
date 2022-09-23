CREATE TABLE [dbo].[purchase_transport_cost]
(
[ptc_id] [int] NOT NULL IDENTITY(1, 1),
[ptc_origin] [int] NULL,
[ptc_destination] [int] NULL,
[ptc_linehaul] [money] NULL,
[ptc_linehaul_permile] [money] NULL,
[ptc_fsc_table] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ptc_date] [datetime] NULL,
[ptc_amtover] [money] NULL,
[ptc_amtover_basis] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ptc_level] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ptc_locked] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ptc_minmargin] [decimal] (5, 2) NULL,
[ptc_minmargin_basis] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ptc_minmargin_locked] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ptc_mode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ptc_updateddate] [datetime] NULL,
[ptc_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_purchase_transport_cost] ON [dbo].[purchase_transport_cost]
FOR UPDATE
AS
DECLARE @min_id		INTEGER,
        @tmwuser 	VARCHAR(255)
exec gettmwuser @tmwuser output

SET @min_id = 0
SELECT @min_id = MIN(ptc_id)
  FROM inserted
 WHERE ptc_id > @min_id

WHILE @min_id > 0 
BEGIN

   IF @min_id IS NULL
      BREAK

   UPDATE purchase_transport_cost
      SET ptc_updatedby = @tmwuser,
          ptc_updateddate = GETDATE()
    WHERE ptc_id = @min_id

   SELECT @min_id = MIN(ptc_id)
     FROM inserted
    WHERE ptc_id > @min_id

END

GO
ALTER TABLE [dbo].[purchase_transport_cost] ADD CONSTRAINT [pk_purchase_transport_cost_ptc_id] PRIMARY KEY CLUSTERED ([ptc_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_purchase_transport_cost_composite] ON [dbo].[purchase_transport_cost] ([ptc_origin], [ptc_destination], [ptc_mode], [ptc_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[purchase_transport_cost] TO [public]
GO
GRANT INSERT ON  [dbo].[purchase_transport_cost] TO [public]
GO
GRANT REFERENCES ON  [dbo].[purchase_transport_cost] TO [public]
GO
GRANT SELECT ON  [dbo].[purchase_transport_cost] TO [public]
GO
GRANT UPDATE ON  [dbo].[purchase_transport_cost] TO [public]
GO
