CREATE TABLE [dbo].[ace_inbond_data]
(
[aid_record_id] [int] NOT NULL IDENTITY(1, 1),
[aid_shipment_number] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[aid_entry_type] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[aid_usport] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[aid_foreignport] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[aid_entryno] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[aid_controlno] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[aid_scac_forward] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[aid_fda_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[aid_departure] [datetime] NULL,
[aid_firms_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_number] [int] NULL,
[aid_bonded_carrier] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ace_inbond_data] ADD CONSTRAINT [PK__ace_inbond_data__6A70EF35] PRIMARY KEY CLUSTERED ([aid_record_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ace_inbond_data] TO [public]
GO
GRANT INSERT ON  [dbo].[ace_inbond_data] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ace_inbond_data] TO [public]
GO
GRANT SELECT ON  [dbo].[ace_inbond_data] TO [public]
GO
GRANT UPDATE ON  [dbo].[ace_inbond_data] TO [public]
GO
