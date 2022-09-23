CREATE TABLE [dbo].[trailer_cleaning_history]
(
[tch_id] [int] NOT NULL IDENTITY(1, 1),
[trl_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fbc_compartm_number] [int] NOT NULL CONSTRAINT [DF__trailer_c__fbc_c__41923459] DEFAULT ((0)),
[tch_date] [datetime] NOT NULL CONSTRAINT [DF__trailer_c__tch_d__42865892] DEFAULT (getdate()),
[tch_usr] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_hdrnumber] [int] NOT NULL,
[mov_number] [int] NOT NULL,
[lgh_number] [int] NOT NULL,
[cmd_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__trailer_c__cmd_c__437A7CCB] DEFAULT ('UNKNOWN'),
[cmd_class] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__trailer_c__cmd_c__446EA104] DEFAULT ('UNKNOWN'),
[cmd_class2] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__trailer_c__cmd_c__4562C53D] DEFAULT ('UNKNOWN'),
[scm_subcode] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_cleaning] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trailer_cleaning_history] ADD CONSTRAINT [PK__trailer_cleaning__409E1020] PRIMARY KEY CLUSTERED ([tch_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tch_altidx] ON [dbo].[trailer_cleaning_history] ([trl_id], [fbc_compartm_number], [tch_date] DESC) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trailer_cleaning_history] TO [public]
GO
GRANT INSERT ON  [dbo].[trailer_cleaning_history] TO [public]
GO
GRANT SELECT ON  [dbo].[trailer_cleaning_history] TO [public]
GO
GRANT UPDATE ON  [dbo].[trailer_cleaning_history] TO [public]
GO
