<script setup lang="ts">
import LoadingBar from '@/shared/components/LoadingBar/index.vue';
import ToastContainer from '@/shared/components/ToastContainer/index.vue';
</script>

<template>
    <LoadingBar />
    <ToastContainer />
    <RouterView />
</template>
