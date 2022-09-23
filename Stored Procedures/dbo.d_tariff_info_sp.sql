SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[d_tariff_info_sp] ( @p_tarnum             int
        )
as
/*
PTS51331 add name to cht_rollintolh and return tariff number

*/

SELECT tariffheader.cht_itemcode,
      tar_rowbasis,
      tar_colbasis, 
      isnull(ivd_description ,'') ivd_description,
			cht_basis,
			cht_basisunit,
			cht_sign,
			IsNull(tariffheader.cht_rollintolh,0) cht_rollintolh,
			tariffheader.cht_lh_rev,
			tariffheader.cht_lh_min,
			tariffheader.cht_lh_stl,
			tariffheader.cht_lh_prn,
			tariffheader.cht_lh_rpt,
			IsNull(tariffheader.ivd_description,''),
			cht_taxtable1,cht_taxtable2,cht_taxtable3,cht_taxtable4,
			cht_glnum,
			isnull(tar_roundunits,999) tar_roundunits,
            tar_number
			FROM tariffheader
			join chargetype on tariffheader.cht_itemcode = chargetype.cht_itemcode
			where tar_number = @p_Tarnum
			
			--PTS 57838 JJF 20110707 - select not needed
			--select * from tariffheader
			--END PTS 57838  JJF 20110707 
			
GO
GRANT EXECUTE ON  [dbo].[d_tariff_info_sp] TO [public]
GO
