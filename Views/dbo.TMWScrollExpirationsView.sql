SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TMWScrollExpirationsView] AS

SELECT Expiration.[exp_idtype] as exp_idtype
      ,Expiration.[exp_id] as exp_id
      ,eat.[updated_by] as created_by
      ,Expiration.[exp_code] as exp_code
      ,Expiration.[exp_lastdate] as exp_lastdate
      ,Expiration.[exp_expirationdate] as exp_expirationdate
      ,Expiration.[exp_routeto] as exp_routeto
      ,Expiration.[exp_completed] as exp_completed
      ,Expiration.[exp_priority] as exp_priority
      ,lbl.[name] as priority_description
      ,Expiration.[exp_compldate] as exp_compldate
      ,Expiration.[exp_updateby] as exp_updateby
      ,Expiration.[exp_creatdate] as exp_creatdate
      ,Expiration.[exp_updateon] as exp_updateon
      ,Expiration.[exp_description] as exp_description
      ,Expiration.[exp_key] as exp_key
      ,CityResolved.[cty_nmstct]
      ,Expiration.[exp_city] as exp_city
      ,TractorResolved.[trc_type1]
      ,TractorResolved.[trc_type2]
      ,TractorResolved.[trc_type3]
      ,TractorResolved.[trc_type4]
      ,TractorResolved.[trc_fleet]
      ,TractorResolved.[trc_division]
      ,TractorResolved.[trc_company]
      ,TractorResolved.[trc_terminal]
      ,TrailerResolved.[trl_type1]
      ,TrailerResolved.[trl_type2]
      ,TrailerResolved.[trl_type3]
      ,TrailerResolved.[trl_type4]
      ,TrailerResolved.[trl_fleet]
      ,TrailerResolved.[trl_division]
      ,TrailerResolved.[trl_company]
      ,TrailerResolved.[trl_terminal]
      ,DriverResolved.[mpp_type1]
      ,DriverResolved.[mpp_type2]
      ,DriverResolved.[mpp_type3]
      ,DriverResolved.[mpp_type4]
      ,DriverResolved.[mpp_fleet]
      ,DriverResolved.[mpp_division]
      ,DriverResolved.[mpp_company]
      ,DriverResolved.[mpp_terminal]
      ,DriverResolved.[mpp_domicile]
      ,DriverResolved.[mpp_teamleader]
      ,CarrierResolved.[car_type1]
      ,CarrierResolved.[car_type2]
      ,CarrierResolved.[car_type3]
      ,CarrierResolved.[car_type4]
      ,CompanyResolved.[cmp_revtype1]
      ,CompanyResolved.[cmp_revtype2]
      ,CompanyResolved.[cmp_revtype3]
      ,CompanyResolved.[cmp_revtype4]
      ,ThirdPartyResolved.[tpr_revtype1]
      ,ThirdPartyResolved.[tpr_revtype2]
      ,ThirdPartyResolved.[tpr_revtype3]
      ,ThirdPartyResolved.[tpr_revtype4]
FROM dbo.expiration Expiration with (NOLOCK) LEFT OUTER JOIN dbo.city CityResolved (NOLOCK) ON Expiration.exp_city = CityResolved.cty_code
											 LEFT OUTER JOIN dbo.tractorprofile TractorResolved (NOLOCK) ON Expiration.exp_id = TractorResolved.trc_number And Expiration.exp_idtype = 'TRC'
											 LEFT OUTER JOIN dbo.trailerprofile TrailerResolved (NOLOCK) ON Expiration.exp_id = TrailerResolved.trl_id And Expiration.exp_idtype = 'TRL'
											 LEFT OUTER JOIN dbo.manpowerprofile DriverResolved (NOLOCK) ON Expiration.exp_id = DriverResolved.mpp_id And Expiration.exp_idtype = 'DRV'
											 LEFT OUTER JOIN dbo.carrier CarrierResolved (NOLOCK) ON Expiration.exp_id = CarrierResolved.car_id And Expiration.exp_idtype = 'CAR'
											 LEFT OUTER JOIN dbo.company CompanyResolved (NOLOCK) ON Expiration.exp_id = CompanyResolved.cmp_id And Expiration.exp_idtype = 'CMP'
											 LEFT OUTER JOIN dbo.thirdpartyprofile ThirdPartyResolved (NOLOCK) ON Expiration.exp_id = ThirdPartyResolved.tpr_id And Expiration.exp_idtype = 'TPR'
											 LEFT OUTER JOIN dbo.expedite_audit eat (nolock) on Expiration.exp_key = eat.key_value and eat.activity = 'ExpirationInsert'
											 LEFT OUTER JOIN dbo.labelfile lbl (NOLOCK) on Expiration.exp_priority = lbl.abbr and lbl.labeldefinition = 'ExpPriority'

GO
GRANT DELETE ON  [dbo].[TMWScrollExpirationsView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollExpirationsView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollExpirationsView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollExpirationsView] TO [public]
GO
