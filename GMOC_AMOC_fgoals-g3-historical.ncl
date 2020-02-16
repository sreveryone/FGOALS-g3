load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

plot_format        = "x11"
plot_name          = get_script_prefix_name()
plot_color         = "ncl_default" ;"NCV_banded"  ;"ncl_default" ;"NCV_blu_red" ;"MPL_RdBu" ;"matlab_jet" ;"amwg256" ;"BlueRed" ;"MPL_bwr" ;"NCV_jet" ;"BlueDarkRed18"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;********* global**************
; fin1               = addfile("/data05/linpf/FGOALS-g3/data/MM_1To12-ee14d-6ensmean.nc","r")
fin1               = addfile("/data05/linpf/FGOALS-g3/data/Yr_1850To2016.nc","r")

apsie1      = fin1->psi_euler(:,:,:,0) ; [time | 12] x [lev1 | 31] x [lat_aux | 316] x [basin | 2]
apsid1       = fin1->psi_eddy(:,:,:,0)  ;(time, lev1, lat_aux, basin)

apsi1 = apsid1
apsi1              = apsie1+apsid1         ; 大西洋的psi (lev, lat)
printVarSummary(apsi1)
delete([/apsie1,apsid1/])
;********* atlantic**************

apsie2       = fin1->psi_euler(:,:,:,1) ; [time | 12] x [lev1 | 31] x [lat_aux | 316] x [basin | 2]
apsid2       = fin1->psi_eddy(:,:,:,1)  ;(time, lev1, lat_aux, basin)
apsi2 = apsid2
apsi2              = apsie2+apsid2         ; 大西洋的psi (lev, lat)
;printVarSummary(apsi2)
delete([/apsie2,apsid2/])
;******************** amoc & gmoc *********************************
gmoc1              = dim_avg_n_Wrap(apsi1,0)
amoc1              = dim_avg_n_Wrap(apsi2,0)
;print(gmoc1)
lev1 = fin1->lev1
print(lev1)
;fin2               = addfile("/ldata5/OMIP1_OMIP2/data/COREII_JRA55/OMIP2_msftmyz_001To366_yearmean_lat_intlevel_setzaxis.nc","r")
;gpsi2              = fin2->msftmyz(327:356,0,:,:)
;apsi2              = fin2->msftmyz(327:356,1,:,:)
;printVarSummary(gpsi2)
;gmoc2              = dim_avg_n_Wrap(gpsi2,0)
;amoc2              = dim_avg_n_Wrap(apsi2,0)
;printVarSummary(gmoc2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

wks  = gsn_open_wks(plot_format,get_script_prefix_name)
gsn_define_colormap(wks,plot_color)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

res0                                     = True
res0@gsnDraw                             = False
res0@gsnFrame                            = False
res0@cnFillOn                            = False
res0@cnInfoLabelOn                       = False
res0@cnLinesOn                           = True
res0@cnLineLabelsOn                      = True
res0@tmXBOn                              = False
res0@trYReverse                          = True
res0@gsnContourNegLineDashPattern        = 1
res0@gsnContourZeroLineThicknessF        = 2.5
res0@gsnLeftString                       = ""
res0@gsnRightString                      = ""
res0@cnLevelSelectionMode                = "ExplicitLevels"
;res0@cnLevels                            = (/-6.0,-4.0,-2.0,0.0,2.0,4.0,6.0,8.0,12.0,16.0,20.0,24.0,28.0/)
res0@cnLevels                            = (/-32,-28,-24,-20,-16,-12,-8,-4,0,4,8,12,16,20,24,28,32/)

res0@cnExplicitLineLabelsOn              = True
;res0@cnLineLabelStrings                  = (/"","-4","","0.0","","4.0","","8.0","12.0","16.0","20.0","24.0",""/)
res0@cnLineLabelStrings                  =(/"-32","","-24","","-16","","-8","","0","","8","","16","","24","","32"/)

res0@cnLineLabelDensityF                  = 1.
res0@cnLineLabelInterval                  = 1
res0@cnLineLabelFont                      = "times-roman"
res0@cnLineLabelsOn                      = True
res0@cnLabelMasking                      = True
res0@cnLineLabelBackgroundColor          = "transparent"
res0@tmXTOn                               = False

res                                      = True
res@gsnFrame                             = False
;res@gsnDraw                             = False
res@cnInfoLabelOn                        = False
res@tmXBLabelFont                        = "times-roman"
res@tmYLLabelFont                        = "times-roman"
res@gsnStringFont                        = "times-roman"
res@lbLabelFont                          = "times-roman"
res@lbTitleFont                          = "times-roman"
res@tiYAxisFont                          = "times-roman"
res@tiXAxisFont                          = "times-roman"
res@tmXBLabelFontHeightF                 = 0.013
res@tmYLLabelFontHeightF                 = 0.013
res@gsnLeftStringFontHeightF             = 0.015
res@gsnCenterStringFontHeightF           = 0.015
res@gsnRightStringFontHeightF            = 0.015
res@tiYAxisFontHeightF                   = 0.014
res@tiXAxisFontHeightF                   = 0.014
;res@gsnCenterStringParallelPosF          = 0.03
;res@gsnLeftStringOrthogonalPosF          = 0.01
;res@gsnCenterStringOrthogonalPosF        = 0.01
;res@gsnRightStringOrthogonalPosF         =-0.04
res@tiMainString                         = ""
res@gsnLeftString                        = ""
res@gsnCenterString                      = ""
res@gsnRightString                       = ""
res@tiYAxisString                        = "Depth(km)"
res@tiXAxisString                        = ""
res@tmXTOn                               = False

res@trXMinF                              =-76.0
res@trXMaxF                              = 90.0
res@gsnYAxisIrregular2Linear             = True
res@gsnXAxisIrregular2Linear             = True
res@tmXBOn                              = False
res@tmXBMode                           = "Explicit"
res@tmXBValues                         = (/-80,-60,-40,-20,0,20,40,60,80.0/)
res@tmXBLabels                         = (/"80~S~o~N~S","60~S~o~N~S","40~S~o~N~S","20~S~o~N~S","0~S~o~N~","20~S~o~N~N","40~S~o~N~N","60~S~o~N~N","80~S~o~N~N"/)
res@tmXBMinorValues                    = fspan(-80,90,18)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bres                                     = res
bres@cnFillOn                            = True
bres@cnMonoFillColor                     = False
bres@cnLinesOn                           = False
bres@cnLineLabelsOn                      = False
;bres@gsnSpreadColorStart                 = 18
;bres@gsnSpreadColorEnd                   = 238
;bres@gsnContourNegLineDashPattern         = 1
;bres@gsnContourPosLineDashPattern         = 0
;bres@gsnContourZeroLineThicknessF         = 2.0

bres@cnLevelSelectionMode               = "ManualLevels"
bres@cnMinLevelValF                     =-32.0
bres@cnMaxLevelValF                     = 32.0
bres@cnLevelSpacingF                    =  4.0

;bres@cnLevelSelectionMode                = "ExplicitLevels"
;bres@cnLevels                            = (/-6.0,-4.0,-3.0,-2.0,-1.0,0.0,1.0,2.0,3.0,4.0,6.0,8.0,10.0,12.0,14.0,16.0,18.0,22.0,26.0/)
;bres@cnMonoFillColor                     = False
;bres@cnFillColors                        = (/28,43,53,65,78,91,116,126,136,146,156,166,176,186,196,206,216,226,236,246/)
;bres@cnExplicitLabelBarLabelsOn          = True
;bres@lbLabelStrings                      = (/"-6.0","-4.0","","-2.0","","0.0","","2.0","","4.0","6.0","8.0","10.0","12.0","14.0","16.0","18.0","22.0","26.0"/)

;***************************** set missing value fill *************************************
bres@cnMissingValPerimOn=True
bres@cnMissingValFillPattern=0
bres@cnMissingValFillColor="gray"

bres@lbLabelBarOn                        = False
bres@lbLabelStride                      = 2
;bres@lbOrientation                      = "vertical"
bres@lbBoxLineColor                      = "seashell2"
bres@lbBoxEndCapStyle                    = "TriangleBothEnds"
bres@lbPerimOn                           = False

bres@lbLabelFontHeightF                  = 0.012
;bres@pmLabelBarOrthogonalPosF            =-0.58
bres@pmLabelBarParallelPosF              = -0.08
bres@pmLabelBarHeightF                   = 0.05
bres@pmLabelBarWidthF                    = 0.8

;bres@lbTitleOn                           = True
;bres@lbTitleString                       = ""
;bres@lbTitleFontHeightF                  = 0.012
;bres@lbTitlePosition                     = "Top"
;bres@lbTitleOffsetF                      =-2.60

bres@tmXTOn                               = False

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bres1                                    = bres
bres1@vpWidthF                           = 0.44
;bres1@vpHeightF                          = 0.10
bres1@vpHeightF                          = 0.30
;bres1@trYMinF                           =-1021.67
bres1@trYReverse                         = False
bres1@trYMaxF                            = 0
bres1@trYMinF                            = -5000
bres1@tmYLMode                           = "Explicit"
;bres1@tmYLValues                         = (/0,-200,-400,-600,-800.0,-1000.0/)
;bres1@tmYLLabels                         = (/"0.0","0.2","0.4","0.6","0.8","1.0"/)
bres1@tmYLValues                         = (/0,-1000,-2000,-3000,-4000,-5000.0/)
bres1@tmYLLabels                         = (/"0.0","1.0","2.0","3.0","4.0","5.0"/)
;bres1@tmYLValues                         = (/0,-100,-200,-300,-400.0,-500.0/)
;bres1@tmYLLabels                         = (/"0.0","0.1","0.2","0.3","0.4","0.5"/)
;bres1@tmXBBorderOn                       = False
bres1@tmXTBorderOn                       = True
bres1@tiYAxisOffsetYF                    = -0.24
bres1@tmYLMinorValues                    = fspan(0,6000.0,31)

bres2                                    = bres
bres2@vpWidthF                           = 0.20
bres2@vpHeightF                          = 0.15
bres2@trYMinF                            =-5200.0
bres2@trYMaxF                           =-1021.67
;bres2@tmXBMode                          = "Explicit"
;bres2@tmXBValues                        = (/-60,-30,0,30,60,90.0/)
;bres2@tmXBLabels                        = (/"60~S~o~N~S","30~S~o~N~S","0~S~o~N~","30~S~o~N~N","60~S~o~N~N","90~S~o~N~N"/)
bres2@tmYLMode                           = "Explicit"
bres2@tmYLValues                         = (/0,-1000,-2000,-3000,-4000,-5000.0/)
bres2@tmYLLabels                         = (/"0.0","1.0","2.0","3.0","4.0","5.0"/)
bres2@tmXBBorderOn                       = True
bres2@tmXTBorderOn                       = False
; bres2@tiYAxisString                      = ""
bres2@gsnLeftString                      = ""
bres2@gsnRightString                     = ""

;bres1@tmXBMajorLengthF                  = 0.004
;bres1@tmYLMajorLengthF                  = 0.001
;bres1@tmXBMajorOutwardLengthF           = 0.004
;bres1@gsnSpreadColorStart               = 18
;bres1@gsnSpreadColorEnd                 = 235
;bres1@tmYLLabelsOn                      = False

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bres101                                  = bres1
;bres101@trYReverse                       = True
bres101@vpXF                             = 0.05
bres101@vpYF                             = 0.7
bres101@tmYLOn                           = True
bres101@tmYROn                           = False
bres101@tmXBOn                           = True
;bres101@tmXTOn                           = True
bres101@tmXBLabelsOn                     = True
; bres101@tiYAxisString                    = ""
bres101@gsnLeftString                    = "(a) GMOC"
bres101@gsnRightString                   = ""
plot102                                  = gsn_csm_contour(wks,gmoc1,bres101) ; plot fill
plot11                                   = gsn_csm_contour(wks,gmoc1,res0) ; plot lines
overlay(plot102, plot11)
draw(plot102)

;print(max(gmoc1({2000:500},{10:60})))
;print(min(gmoc1({6000:2000},{10:60})))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bres102                                  = bres1
;bres102@trYReverse                       = True
bres102@lbLabelBarOn                     = False
bres102@tmXBLabelsOn                     = True
bres102@vpXF                             = 0.05
bres102@vpYF                             = 0.61
bres102@tmYLOn                           = True
bres102@tmYROn                           = False
bres102@tmXBOn                           = True
;bres102@tmXTOn                           = True
; bres102@tiYAxisString                    = ""
bres102@gsnLeftString                    = "b) OMIP2"
bres102@gsnRightString                   = "GMOC"
;plot102                                  = gsn_csm_contour(wks,gmoc2,bres102)
;plot11                                   = gsn_csm_contour(wks,gmoc2,res0)
;overlay(plot102, plot11)
;draw(plot102)

;print(max(gmoc2({2000:500},{10:60})))
;print(min(gmoc2({6000:2000},{10:60})))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bres1@trXMinF                              =-35.0
bres1@trXMaxF                              = 90.0

bres103                                  = bres1
bres103@lbLabelBarOn                     = True ; turn on labelbar
;bres103@trYReverse                       = True
bres103@vpXF                             = 0.55
bres103@vpYF                             = 0.7
bres103@tmYLOn                           = True
bres103@tmYROn                           = False
bres103@tmXBOn                           = True
;bres103@tmXTOn                           = True
bres103@tmXBLabelsOn                     = True
; bres103@tiYAxisString                    = ""
bres103@gsnLeftString                    = "(b) AMOC"
bres103@gsnRightString                   = ""
plot102                                  = gsn_csm_contour(wks,amoc1,bres103)
plot11                                   = gsn_csm_contour(wks,amoc1,res0)
overlay(plot102, plot11)
draw(plot102)


;print(max(amoc1({2000:500},{10:60})))
;print(min(amoc1({6000:2000},{10:60})))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bres104                                  = bres1
;bres104@trYReverse                       = True
bres104@lbLabelBarOn                     = True
bres104@lbLabelBarOn                        = True
;bres104@lbTitleFontHeightF                   = 0.02
;bres104@lbTitlePosition                      = "right"
;bres104@lbTitleDirection                     = "Across"
;bres104@lbTitleString                       = "Sv"
;bres104@lbTitleOffsetF                   = 0.02
bres104@tmXBLabelsOn                     = True
bres104@vpXF                             = 0.55
bres104@vpYF                             = 0.61
bres104@tmYLOn                           = True
bres104@tmYROn                           = False
bres104@tmXBOn                           = True
;bres104@tmXTOn                           = True
; bres104@tiYAxisString                    = ""
bres104@gsnLeftString                    = "d) OMIP2"
bres104@gsnRightString                   = "AMOC"
;plot102                                  = gsn_csm_contour(wks,amoc2,bres104)
;plot11                                   = gsn_csm_contour(wks,amoc2,res0)
;overlay(plot102, plot11)
;draw(plot102)

;print(max(amoc2({2000:500},{10:60})))
;print(min(amoc2({6000:2000},{10:60})))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

frame(wks)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


end



