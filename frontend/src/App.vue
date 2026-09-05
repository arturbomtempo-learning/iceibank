<script setup lang="ts">
import LoadingBar from '@/shared/components/LoadingBar.vue';
import ToastContainer from '@/shared/components/ToastContainer.vue';
</script>

<template>
    <LoadingBar />
    <ToastContainer />
    <RouterView />
</template>
