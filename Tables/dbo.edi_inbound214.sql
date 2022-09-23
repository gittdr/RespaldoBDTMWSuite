CREATE TABLE [dbo].[edi_inbound214]
(
[id_num] [int] NOT NULL IDENTITY(1, 1),
[ord_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NULL,
[stp_number] [int] NULL,
[car_edi_scac] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_trip_id] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edi_code] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edi_reasoncode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_dt] [datetime] NULL,
[created_dt] [datetime] NULL,
[process_status] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orig_update_dt] [datetime] NULL,
[orig_edi_reasoncode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status_city] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status_state] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stop_latitude] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stop_longitude] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rejection_error_reason] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_number] [int] NULL,
[warning_reason] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trailer_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trailer2_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trailer3_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trailer4_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[it_edi_inbound214]
ON [dbo].[edi_inbound214]
FOR INSERT AS
--DECLARE @id_num		INTEGER,
--        @update_dt	DATETIME,
--	@edi_reasoncode	VARCHAR(2)

 --  SELECT @id_num = inserted.id_num,
 --         @update_dt = inserted.update_dt,
  --        @edi_reasoncode = inserted.edi_reasoncode
 --    FROM inserted 

   UPDATE edi_inbound214
      SET orig_update_dt = inserted.update_dt,
          orig_edi_reasoncode =  inserted.edi_reasoncode
         from inserted
    WHERE edi_inbound214.id_num =  inserted.id_num

GO
ALTER TABLE [dbo].[edi_inbound214] ADD CONSTRAINT [pk_edi_inbound214] PRIMARY KEY CLUSTERED ([id_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_edi_inbound214_lgh_number] ON [dbo].[edi_inbound214] ([lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_eis_ord_hdrnumber_214] ON [dbo].[edi_inbound214] ([ord_hdrnumber]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_edi_inbound214_process_status_lgh_number] ON [dbo].[edi_inbound214] ([process_status], [lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_eis_stp_number] ON [dbo].[edi_inbound214] ([stp_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_inbound214] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_inbound214] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_inbound214] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_inbound214] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_inbound214] TO [public]
GO
