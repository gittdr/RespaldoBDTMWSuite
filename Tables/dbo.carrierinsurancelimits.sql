CREATE TABLE [dbo].[carrierinsurancelimits]
(
[cal_id] [int] NOT NULL IDENTITY(1, 1),
[cai_id] [int] NULL,
[cal_limit] [money] NULL,
[cal_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cal_source] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_carrierinsurancelimits_cai_id_cal_description] ON [dbo].[carrierinsurancelimits] ([cai_id], [cal_description]) INCLUDE ([cal_limit]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrierinsurancelimits] ADD CONSTRAINT [FK__carrierin__cai_i__51D6E840] FOREIGN KEY ([cai_id]) REFERENCES [dbo].[carrierinsurance] ([cai_id]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[carrierinsurancelimits] TO [public]
GO
GRANT INSERT ON  [dbo].[carrierinsurancelimits] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrierinsurancelimits] TO [public]
GO
GRANT SELECT ON  [dbo].[carrierinsurancelimits] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrierinsurancelimits] TO [public]
GO
