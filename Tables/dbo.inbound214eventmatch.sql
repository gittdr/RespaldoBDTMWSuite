CREATE TABLE [dbo].[inbound214eventmatch]
(
[iem_id] [int] NOT NULL IDENTITY(1, 1),
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edi_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[inbound214eventmatch] ADD CONSTRAINT [pk_inbound214eventmatch_iem_id] PRIMARY KEY CLUSTERED ([iem_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_inbound214eventmatch_car_id] ON [dbo].[inbound214eventmatch] ([car_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[inbound214eventmatch] TO [public]
GO
GRANT INSERT ON  [dbo].[inbound214eventmatch] TO [public]
GO
GRANT REFERENCES ON  [dbo].[inbound214eventmatch] TO [public]
GO
GRANT SELECT ON  [dbo].[inbound214eventmatch] TO [public]
GO
GRANT UPDATE ON  [dbo].[inbound214eventmatch] TO [public]
GO
