CREATE TABLE [dbo].[menu_position]
(
[mp_position] [int] NOT NULL,
[mp_ord] [int] NULL CONSTRAINT [DF__menu_posi__mp_or__3C895D9D] DEFAULT (0),
[mp_vd] [int] NULL CONSTRAINT [DF__menu_posi__mp_vd__3D7D81D6] DEFAULT (0),
[mp_inv] [int] NULL CONSTRAINT [DF__menu_posi__mp_in__3E71A60F] DEFAULT (0),
[mp_set] [int] NULL CONSTRAINT [DF__menu_posi__mp_se__3F65CA48] DEFAULT (0),
[mp_adm] [int] NULL CONSTRAINT [DF__menu_posi__mp_ad__4059EE81] DEFAULT (0),
[mp_fil] [int] NULL CONSTRAINT [DF__menu_posi__mp_fi__414E12BA] DEFAULT (0),
[mp_tar] [int] NULL CONSTRAINT [DF__menu_posi__mp_ta__424236F3] DEFAULT (0),
[mp_psa] [int] NULL CONSTRAINT [DF__menu_posi__mp_ps__43365B2C] DEFAULT (0),
[mp_aoe] [int] NULL CONSTRAINT [DF__menu_posi__mp_ao__442A7F65] DEFAULT (0),
[mp_eta] [int] NULL CONSTRAINT [DF__menu_posi__mp_et__451EA39E] DEFAULT (0),
[mp_gps] [int] NULL CONSTRAINT [DF__menu_posi__mp_gp__4612C7D7] DEFAULT (0),
[mp_xfc] [int] NULL CONSTRAINT [DF__menu_posi__mp_xf__4706EC10] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[menu_position] ADD CONSTRAINT [PK__menu_position__3B953964] PRIMARY KEY CLUSTERED ([mp_position]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[menu_position] TO [public]
GO
GRANT INSERT ON  [dbo].[menu_position] TO [public]
GO
GRANT REFERENCES ON  [dbo].[menu_position] TO [public]
GO
GRANT SELECT ON  [dbo].[menu_position] TO [public]
GO
GRANT UPDATE ON  [dbo].[menu_position] TO [public]
GO
