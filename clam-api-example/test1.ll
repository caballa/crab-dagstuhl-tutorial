; ModuleID = '/var/folders/3c/x7v9dc9d4r57p3nphrqty8sc0000gn/T/clam-mhqnatpf/test1.pp.bc'
source_filename = "test1.c"
target datalayout = "e-m:o-p:32:32-Fi8-f64:32:64-v64:32:64-v128:32:128-a:0:32-n32-S32"
target triple = "armv4t-apple-macosx13.0.0"

; Function Attrs: noinline nounwind ssp
define internal fastcc i8* @xmalloc(i32 %sz) unnamed_addr #0 {
entry:
  %call = call i8* @malloc(i32 %sz) #3
  %cmp = icmp ne i8* %call, null
  %conv = zext i1 %cmp to i32
  call void @__CRAB_assume(i32 %conv) #4
  ret i8* %call
}

; Function Attrs: allocsize(0)
declare i8* @malloc(i32) local_unnamed_addr #1

; Function Attrs: argmemonly nounwind
declare void @__CRAB_assume(i32) local_unnamed_addr #2

; Function Attrs: noinline nounwind ssp
define internal fastcc i32 @nondet_size(i32 %lb, i32 %ub) unnamed_addr #0 {
entry:
  %call = call i32 @nd_int() #4
  %cmp = icmp sle i32 %lb, %call
  %conv = zext i1 %cmp to i32
  call void @__CRAB_assume(i32 %conv) #4
  %cmp1 = icmp sle i32 %call, %ub
  %conv2 = zext i1 %cmp1 to i32
  call void @__CRAB_assume(i32 %conv2) #4
  ret i32 %call
}

; Function Attrs: argmemonly nounwind
declare i32 @nd_int() local_unnamed_addr #2

; Function Attrs: noinline nounwind ssp
define i32 @main() local_unnamed_addr #0 {
entry:
  %call = call fastcc i32 @nondet_size(i32 10, i32 1000)
  %mul = mul i32 %call, 4
  %call1 = call fastcc i8* @xmalloc(i32 %mul)
  %_0 = bitcast i8* %call1 to i32*
  %cmp5 = icmp slt i32 0, %call
  br i1 %cmp5, label %for.body.peel, label %for.cond6.preheader

for.body.peel:                                    ; preds = %entry
  %call2.peel = call i32 @nd_int() #4
  %cmp3.peel = icmp slt i32 -1, %call2.peel
  %conv.peel = zext i1 %cmp3.peel to i32
  call void @__CRAB_assume(i32 %conv.peel) #4
  %cmp4.peel = icmp slt i32 %call2.peel, 100
  %conv5.peel = zext i1 %cmp4.peel to i32
  call void @__CRAB_assume(i32 %conv5.peel) #4
  %arrayidx.peel = getelementptr inbounds i32, i32* %_0, i32 0
  store i32 %call2.peel, i32* %arrayidx.peel, align 4
  %inc.peel = add nuw nsw i32 0, 1
  %cmp.peel = icmp slt i32 %inc.peel, %call
  br i1 %cmp.peel, label %for.body, label %for.cond6.preheader

for.cond6.preheader:                              ; preds = %for.body, %for.body.peel, %entry
  %cmp71 = icmp slt i32 0, %call
  br i1 %cmp71, label %for.body9.peel, label %for.end15

for.body9.peel:                                   ; preds = %for.cond6.preheader
  %arrayidx10.peel = getelementptr inbounds i32, i32* %_0, i32 0
  %_1 = load i32, i32* %arrayidx10.peel, align 4
  %cmp11.peel = icmp slt i32 %_1, 100
  %conv12.peel = zext i1 %cmp11.peel to i32
  call void @__CRAB_assert(i32 %conv12.peel) #4
  %inc14.peel = add nuw nsw i32 0, 1
  %cmp7.peel = icmp slt i32 %inc14.peel, %call
  br i1 %cmp7.peel, label %for.body9, label %for.end15

for.body:                                         ; preds = %for.body, %for.body.peel
  %i.06 = phi i32 [ %inc, %for.body ], [ %inc.peel, %for.body.peel ]
  %call2 = call i32 @nd_int() #4
  %cmp3 = icmp slt i32 -1, %call2
  %conv = zext i1 %cmp3 to i32
  call void @__CRAB_assume(i32 %conv) #4
  %cmp4 = icmp slt i32 %call2, 100
  %conv5 = zext i1 %cmp4 to i32
  call void @__CRAB_assume(i32 %conv5) #4
  %arrayidx = getelementptr inbounds i32, i32* %_0, i32 %i.06
  store i32 %call2, i32* %arrayidx, align 4
  %inc = add nuw nsw i32 %i.06, 1
  %exitcond9 = icmp slt i32 %inc, %call
  br i1 %exitcond9, label %for.body, label %for.cond6.preheader, !llvm.loop !6

for.body9:                                        ; preds = %for.body9, %for.body9.peel
  %j.02 = phi i32 [ %inc14, %for.body9 ], [ %inc14.peel, %for.body9.peel ]
  %arrayidx10 = getelementptr inbounds i32, i32* %_0, i32 %j.02
  %_2 = load i32, i32* %arrayidx10, align 4
  %cmp11 = icmp slt i32 %_2, 100
  %conv12 = zext i1 %cmp11 to i32
  call void @__CRAB_assert(i32 %conv12) #4
  %inc14 = add nuw nsw i32 %j.02, 1
  %exitcond = icmp slt i32 %inc14, %call
  br i1 %exitcond, label %for.body9, label %for.end15, !llvm.loop !9

for.end15:                                        ; preds = %for.body9, %for.body9.peel, %for.cond6.preheader
  ret i32 0
}

; Function Attrs: argmemonly nounwind
declare void @__CRAB_assert(i32) local_unnamed_addr #2

attributes #0 = { noinline nounwind ssp "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm7tdmi" "target-features"="+armv4t,+soft-float,+strict-align,-aes,-bf16,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-mve,-mve.fp,-neon,-sha2,-thumb-mode,-vfp2,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "use-soft-float"="true" }
attributes #1 = { allocsize(0) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm7tdmi" "target-features"="+armv4t,+soft-float,+strict-align,-aes,-bf16,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-mve,-mve.fp,-neon,-sha2,-thumb-mode,-vfp2,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "use-soft-float"="true" }
attributes #2 = { argmemonly nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm7tdmi" "target-features"="+armv4t,+soft-float,+strict-align,-aes,-bf16,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-mve,-mve.fp,-neon,-sha2,-thumb-mode,-vfp2,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "use-soft-float"="true" }
attributes #3 = { nounwind allocsize(0) }
attributes #4 = { argmemonly nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 13, i32 1]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 1, !"min_enum_size", i32 4}
!3 = !{i32 7, !"PIC Level", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Apple clang version 14.0.0 (clang-1400.0.29.202)"}
!6 = distinct !{!6, !7, !8}
!7 = !{!"llvm.loop.mustprogress"}
!8 = !{!"llvm.loop.peeled.count", i32 1}
!9 = distinct !{!9, !7, !8}
