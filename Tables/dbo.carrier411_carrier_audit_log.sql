CREATE TABLE [dbo].[carrier411_carrier_audit_log]
(
[cab_batch_number] [int] NOT NULL,
[cas_docket_number] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__carrier41__cas_d__1F24E060] DEFAULT ('UNKNOWN'),
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__carrier41__car_i__20190499] DEFAULT ('UNKNOWN'),
[car_iccnum] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cab_legal_name] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_name] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[audit_result] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrier411_carrier_audit_log] ADD CONSTRAINT [PK__carrier411_carri__1E30BC27] PRIMARY KEY CLUSTERED ([cab_batch_number], [cas_docket_number], [car_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrier411_carrier_audit_log] TO [public]
GO
GRANT INSERT ON  [dbo].[carrier411_carrier_audit_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrier411_carrier_audit_log] TO [public]
GO
GRANT SELECT ON  [dbo].[carrier411_carrier_audit_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrier411_carrier_audit_log] TO [public]
GO
