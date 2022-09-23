SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TMWScrollCarrierView] AS
SELECT
		car_id,
		car_name,
		car_phone1,
		car_status,
		car_address1,
		car_contact,
		city.cty_nmstct, 
		cty_state,
		car_zip,
		car_fedid,
		car_scac,
		car_otherid,
		car_phone3,
		car_phone2,
		car_type1,
		car_type2,
		car_type3,
		car_type4,
		car_iccnum,
		ISNULL(car_exp1_date,'12/31/49') as car_exp1_date,
		ISNULL(car_exp2_date,'12/31/49') as car_exp2_date,
		car_score,
		car_dotnum
FROM	CarrierRowRestrictedView car with (NOLOCK) 
		LEFT JOIN city WITH (NOLOCK) ON car.cty_code = city.cty_code
GO
GRANT DELETE ON  [dbo].[TMWScrollCarrierView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollCarrierView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollCarrierView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollCarrierView] TO [public]
GO
